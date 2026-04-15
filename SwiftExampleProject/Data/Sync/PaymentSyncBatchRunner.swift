import Foundation

/// Drains the outbox by repeatedly running `ProcessPendingPaymentsUseCase` until empty or until a submission error.
@MainActor
struct PaymentSyncBatchRunner {
    private let paymentRepository: PaymentRepository
    private let processOne: ProcessPendingPaymentsUseCase

    init(paymentRepository: PaymentRepository, processOne: ProcessPendingPaymentsUseCase) {
        self.paymentRepository = paymentRepository
        self.processOne = processOne
    }

    func processQueueUntilEmptyOrError() async throws {
        while true {
            let ready = await paymentRepository.fetchReadyForSync()
            guard !ready.isEmpty else { return }
            try await processOne.execute()
        }
    }
}
