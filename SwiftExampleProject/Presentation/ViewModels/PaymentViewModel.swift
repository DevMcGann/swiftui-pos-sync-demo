import Foundation
import Observation

@MainActor
@Observable
final class PaymentViewModel {
    private static let demoWalkInCustomer = Customer(
        id: "demo-walk-in",
        name: "Walk-in (demo)",
        email: "walk-in@demo.local"
    )

    var amountText = ""
    var currencyCode = "USD"
    var selectedCustomerId = ""

    private(set) var customers: [Customer] = []
    private(set) var latestCardRead: CardReadResult?
    private(set) var payments: [PaymentTransaction] = []

    private(set) var isLoading = false
    private(set) var isCreating = false
    private(set) var isSyncBusy = false
    private(set) var enqueueingPaymentId: String?
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    private let createPaymentDraftUseCase: CreatePaymentDraftUseCase
    private let loadLocalCustomersUseCase: LoadLocalCustomersUseCase
    private let loadAllPaymentsUseCase: LoadAllPaymentsUseCase
    private let enqueuePaymentForSyncUseCase: EnqueuePaymentForSyncUseCase
    private let processPendingPaymentsUseCase: ProcessPendingPaymentsUseCase
    private let paymentSyncBatchRunner: PaymentSyncBatchRunner
    private let retryFailedPaymentsUseCase: RetryFailedPaymentsUseCase
    private let observeCardReadsUseCase: ObserveCardReadsUseCase

    @ObservationIgnored
    private var cardReadTask: Task<Void, Never>?

    init(
        createPaymentDraftUseCase: CreatePaymentDraftUseCase,
        loadLocalCustomersUseCase: LoadLocalCustomersUseCase,
        loadAllPaymentsUseCase: LoadAllPaymentsUseCase,
        enqueuePaymentForSyncUseCase: EnqueuePaymentForSyncUseCase,
        processPendingPaymentsUseCase: ProcessPendingPaymentsUseCase,
        paymentSyncBatchRunner: PaymentSyncBatchRunner,
        retryFailedPaymentsUseCase: RetryFailedPaymentsUseCase,
        observeCardReadsUseCase: ObserveCardReadsUseCase
    ) {
        self.createPaymentDraftUseCase = createPaymentDraftUseCase
        self.loadLocalCustomersUseCase = loadLocalCustomersUseCase
        self.loadAllPaymentsUseCase = loadAllPaymentsUseCase
        self.enqueuePaymentForSyncUseCase = enqueuePaymentForSyncUseCase
        self.processPendingPaymentsUseCase = processPendingPaymentsUseCase
        self.paymentSyncBatchRunner = paymentSyncBatchRunner
        self.retryFailedPaymentsUseCase = retryFailedPaymentsUseCase
        self.observeCardReadsUseCase = observeCardReadsUseCase
        startCardReadSubscription()
    }

    deinit {
        cardReadTask?.cancel()
    }

    var customerChoices: [Customer] {
        if customers.isEmpty {
            [Self.demoWalkInCustomer]
        } else {
            customers
        }
    }

    var latestCardReadSummary: String? {
        guard let read = latestCardRead else { return nil }
        return "\(read.brand) ···· \(read.last4) — \(read.token)"
    }

    var readyForSyncCount: Int {
        payments.filter { $0.status == .pendingSync && $0.syncStatus == .pending }.count
    }

    var failedSyncCount: Int {
        payments.filter { $0.syncStatus == .failed }.count
    }

    var canCreatePayment: Bool {
        guard latestCardRead != nil else { return false }
        guard let amount = normalizedAmountDecimal(), amount > 0 else { return false }
        let currency = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currency.isEmpty else { return false }
        let customerId = effectiveCustomerId
        guard !customerId.isEmpty else { return false }
        return true
    }

    func syncSummary(for payment: PaymentTransaction) -> String {
        switch (payment.status, payment.syncStatus) {
        case (.cardRead, .pending):
            return "Local draft (not queued)"
        case (.pendingSync, .pending):
            return "Ready for sync"
        case (_, .syncing):
            return "Syncing…"
        case (.synced, .synced):
            return "Synced"
        case (.failed, .failed):
            return "Failed"
        default:
            return "\(payment.status.rawValue.replacingOccurrences(of: "_", with: " ")) · \(payment.syncStatus.rawValue)"
        }
    }

    func canEnqueueForSync(_ payment: PaymentTransaction) -> Bool {
        payment.status == .cardRead && payment.syncStatus == .pending
    }

    func loadScreenData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        customers = await loadLocalCustomersUseCase.execute()
        payments = await loadAllPaymentsUseCase.execute()

        if selectedCustomerId.isEmpty || !customerChoices.contains(where: { $0.id == selectedCustomerId }) {
            selectedCustomerId = customerChoices.first?.id ?? ""
        }
    }

    private func refreshPayments() async {
        payments = await loadAllPaymentsUseCase.execute()
    }

    func createPayment() async {
        guard let cardRead = latestCardRead else {
            errorMessage = "Read a card on the Reader tab first."
            return
        }
        guard let amount = normalizedAmountDecimal(), amount > 0 else {
            errorMessage = PaymentDraftError.invalidAmount.userFacingMessage
            return
        }
        let currency = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currency.isEmpty else {
            errorMessage = PaymentDraftError.emptyCurrency.userFacingMessage
            return
        }
        let customerId = effectiveCustomerId
        guard !customerId.isEmpty else {
            errorMessage = PaymentDraftError.emptyCustomerId.userFacingMessage
            return
        }

        isCreating = true
        successMessage = nil
        errorMessage = nil
        defer { isCreating = false }

        do {
            _ = try await createPaymentDraftUseCase.execute(
                customerId: customerId,
                amount: amount,
                currency: currency,
                cardRead: cardRead
            )
            successMessage = "Payment saved locally. Queue it for sync when ready."
            await refreshPayments()
        } catch let error as PaymentDraftError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = "Could not save the payment. Please try again."
        }
    }

    func enqueueForSync(paymentId: String) async {
        successMessage = nil
        errorMessage = nil
        enqueueingPaymentId = paymentId
        defer { enqueueingPaymentId = nil }

        do {
            try await enqueuePaymentForSyncUseCase.execute(paymentId: paymentId)
            successMessage = "Payment queued for sync."
            await refreshPayments()
        } catch let error as PaymentSyncError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = "Could not queue the payment."
        }
    }

    func processNextPendingSync() async {
        guard readyForSyncCount > 0 else { return }
        isSyncBusy = true
        successMessage = nil
        errorMessage = nil
        defer { isSyncBusy = false }

        do {
            try await processPendingPaymentsUseCase.execute()
            successMessage = "Processed one payment."
            await refreshPayments()
        } catch {
            errorMessage = syncProcessFailureMessage
            await refreshPayments()
        }
    }

    func processAllPendingSync() async {
        guard readyForSyncCount > 0 else { return }
        isSyncBusy = true
        successMessage = nil
        errorMessage = nil
        defer { isSyncBusy = false }

        do {
            try await paymentSyncBatchRunner.processQueueUntilEmptyOrError()
            successMessage = "All queued payments were processed."
            await refreshPayments()
        } catch {
            errorMessage = syncProcessFailureMessage
            await refreshPayments()
        }
    }

    func retryFailedPayments() async {
        guard failedSyncCount > 0 else { return }
        isSyncBusy = true
        successMessage = nil
        errorMessage = nil
        defer { isSyncBusy = false }

        do {
            try await retryFailedPaymentsUseCase.execute()
            successMessage = "Failed payments were reset for another sync attempt."
            await refreshPayments()
        } catch {
            errorMessage = "Could not reset failed payments."
            await refreshPayments()
        }
    }

    private var syncProcessFailureMessage: String {
        "Sync failed for a payment. It may be marked as failed — use Retry, then try again."
    }

    private var effectiveCustomerId: String {
        if !selectedCustomerId.isEmpty,
           customerChoices.contains(where: { $0.id == selectedCustomerId }) {
            return selectedCustomerId
        }
        return customerChoices.first?.id ?? ""
    }

    private func normalizedAmountDecimal() -> Decimal? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func startCardReadSubscription() {
        cardReadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = self.observeCardReadsUseCase.execute()
            for await read in stream {
                self.latestCardRead = read
            }
        }
    }
}
