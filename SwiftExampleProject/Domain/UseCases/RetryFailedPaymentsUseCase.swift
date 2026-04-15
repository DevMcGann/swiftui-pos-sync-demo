struct RetryFailedPaymentsUseCase {
    private let paymentRepository: PaymentRepository

    init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    func execute() async throws {
        let failed = await paymentRepository.fetchFailedSyncPayments()
        for payment in failed {
            let retried = payment.updating(status: .pendingSync, syncStatus: .pending)
            try await paymentRepository.savePaymentDraft(retried)
        }
    }
}
