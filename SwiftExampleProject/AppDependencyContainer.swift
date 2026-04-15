import Foundation
import SwiftData

/// Central wiring for the app target. Keeps a single `DemoAuthRepository` actor for consistent session state.
@MainActor
final class AppDependencyContainer {
    let authRepository: DemoAuthRepository
    let customerRepository: CachingCustomerRepository
    let paymentRepository: SwiftDataPaymentRepository
    let paymentSyncGateway: MockPaymentSyncGateway
    let cardReaderService: MockCardReaderService

    init(
        authRepository: DemoAuthRepository = DemoAuthRepository(),
        modelContext: ModelContext,
        paymentSyncGateway: MockPaymentSyncGateway = MockPaymentSyncGateway(),
        cardReaderService: MockCardReaderService = MockCardReaderService()
    ) {
        self.authRepository = authRepository
        self.customerRepository = CachingCustomerRepository(
            localStore: CustomerSwiftDataStore(context: modelContext)
        )
        self.paymentRepository = SwiftDataPaymentRepository(context: modelContext)
        self.paymentSyncGateway = paymentSyncGateway
        self.cardReaderService = cardReaderService
    }

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(authRepository: authRepository)
    }

    func makeRestoreSessionUseCase() -> RestoreSessionUseCase {
        RestoreSessionUseCase(authRepository: authRepository)
    }

    func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCase(authRepository: authRepository)
    }

    func makeRefreshCustomersUseCase() -> RefreshCustomersUseCase {
        RefreshCustomersUseCase(customerRepository: customerRepository)
    }

    func makeLoadLocalCustomersUseCase() -> LoadLocalCustomersUseCase {
        LoadLocalCustomersUseCase(customerRepository: customerRepository)
    }

    func makeObserveReaderConnectionUseCase() -> ObserveReaderConnectionUseCase {
        ObserveReaderConnectionUseCase(cardReaderService: cardReaderService)
    }

    func makeObserveCardReadsUseCase() -> ObserveCardReadsUseCase {
        ObserveCardReadsUseCase(cardReaderService: cardReaderService)
    }

    func makeStartReaderScanningUseCase() -> StartReaderScanningUseCase {
        StartReaderScanningUseCase(cardReaderService: cardReaderService)
    }

    func makeConnectReaderDeviceUseCase() -> ConnectReaderDeviceUseCase {
        ConnectReaderDeviceUseCase(cardReaderService: cardReaderService)
    }

    func makeDisconnectReaderUseCase() -> DisconnectReaderUseCase {
        DisconnectReaderUseCase(cardReaderService: cardReaderService)
    }

    func makeSimulateCardReadUseCase() -> SimulateCardReadUseCase {
        SimulateCardReadUseCase(cardReaderService: cardReaderService)
    }

    func makeCreatePaymentDraftUseCase() -> CreatePaymentDraftUseCase {
        CreatePaymentDraftUseCase(paymentRepository: paymentRepository)
    }

    func makeLoadPendingPaymentsUseCase() -> LoadPendingPaymentsUseCase {
        LoadPendingPaymentsUseCase(paymentRepository: paymentRepository)
    }

    func makeLoadAllPaymentsUseCase() -> LoadAllPaymentsUseCase {
        LoadAllPaymentsUseCase(paymentRepository: paymentRepository)
    }

    func makeEnqueuePaymentForSyncUseCase() -> EnqueuePaymentForSyncUseCase {
        EnqueuePaymentForSyncUseCase(paymentRepository: paymentRepository)
    }

    func makeProcessPendingPaymentsUseCase() -> ProcessPendingPaymentsUseCase {
        ProcessPendingPaymentsUseCase(paymentRepository: paymentRepository, syncGateway: paymentSyncGateway)
    }

    func makeRetryFailedPaymentsUseCase() -> RetryFailedPaymentsUseCase {
        RetryFailedPaymentsUseCase(paymentRepository: paymentRepository)
    }

    func makePaymentSyncBatchRunner() -> PaymentSyncBatchRunner {
        PaymentSyncBatchRunner(
            paymentRepository: paymentRepository,
            processOne: makeProcessPendingPaymentsUseCase()
        )
    }
}
