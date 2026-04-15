import Foundation

struct PaymentTransaction: Equatable, Sendable {
    let id: String
    let customerId: String
    let amount: Decimal
    let currency: String
    let status: TransactionStatus
    let createdAt: Date
    let syncStatus: SyncStatus
    let cardToken: String
    let idempotencyKey: String
    let cardLast4: String?
    let cardBrand: String?
    let readerId: String?
}

extension PaymentTransaction {
    func updating(status: TransactionStatus? = nil, syncStatus: SyncStatus? = nil) -> PaymentTransaction {
        PaymentTransaction(
            id: id,
            customerId: customerId,
            amount: amount,
            currency: currency,
            status: status ?? self.status,
            createdAt: createdAt,
            syncStatus: syncStatus ?? self.syncStatus,
            cardToken: cardToken,
            idempotencyKey: idempotencyKey,
            cardLast4: cardLast4,
            cardBrand: cardBrand,
            readerId: readerId
        )
    }
}
