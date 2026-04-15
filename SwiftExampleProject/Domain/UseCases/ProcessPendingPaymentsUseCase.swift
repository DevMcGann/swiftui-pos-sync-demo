struct ProcessPendingPaymentsUseCase {
    private let paymentRepository: PaymentRepository
    private let syncGateway: PaymentSyncGateway

    init(paymentRepository: PaymentRepository, syncGateway: PaymentSyncGateway) {
        self.paymentRepository = paymentRepository
        self.syncGateway = syncGateway
    }

    func execute() async throws {
        guard var payment = await paymentRepository.fetchReadyForSync().first else { return }

        let syncing = payment.updating(syncStatus: .syncing)
        try await paymentRepository.savePaymentDraft(syncing)
        payment = syncing

        do {
            try await syncGateway.submitPayment(payment)
            let done = payment.updating(status: .synced, syncStatus: .synced)
            try await paymentRepository.savePaymentDraft(done)
        } catch {
            let failed = payment.updating(status: .failed, syncStatus: .failed)
            try await paymentRepository.savePaymentDraft(failed)
            throw error
        }
    }
}
