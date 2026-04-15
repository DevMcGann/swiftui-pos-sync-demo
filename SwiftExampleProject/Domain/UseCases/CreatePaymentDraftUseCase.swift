import Foundation

struct CreatePaymentDraftUseCase {
    private let paymentRepository: PaymentRepository

    init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    func execute(customerId: String, amount: Decimal, currency: String, cardRead: CardReadResult) async throws -> PaymentTransaction {
        guard !customerId.isEmpty else { throw PaymentDraftError.emptyCustomerId }
        guard amount > 0 else { throw PaymentDraftError.invalidAmount }
        guard !currency.isEmpty else { throw PaymentDraftError.emptyCurrency }

        let now = Date()
        let draft = PaymentTransaction(
            id: UUID().uuidString,
            customerId: customerId,
            amount: amount,
            currency: currency,
            status: .cardRead,
            createdAt: now,
            syncStatus: .pending,
            cardToken: cardRead.token,
            idempotencyKey: UUID().uuidString,
            cardLast4: cardRead.last4,
            cardBrand: cardRead.brand,
            readerId: cardRead.readerId
        )

        try await paymentRepository.savePaymentDraft(draft)
        return draft
    }
}
