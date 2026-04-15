struct EnqueuePaymentForSyncUseCase {
    private let paymentRepository: PaymentRepository

    init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    func execute(paymentId: String) async throws {
        guard let payment = await paymentRepository.fetchPayment(id: paymentId) else {
            throw PaymentSyncError.paymentNotFound
        }
        guard payment.status == .cardRead, payment.syncStatus == .pending else {
            throw PaymentSyncError.invalidStateForEnqueue
        }
        let enqueued = payment.updating(status: .pendingSync)
        try await paymentRepository.savePaymentDraft(enqueued)
    }
}
