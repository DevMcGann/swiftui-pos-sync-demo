import Foundation
@testable import SwiftExampleProject

enum PaymentTestFixtures {
    static func transaction(
        id: String = UUID().uuidString,
        customerId: String = "cust-1",
        amount: Decimal = 12.34,
        currency: String = "USD",
        status: TransactionStatus = .cardRead,
        createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000),
        syncStatus: SyncStatus = .pending,
        cardToken: String = "tok-test",
        idempotencyKey: String = "idem-\(UUID().uuidString)",
        cardLast4: String? = "4242",
        cardBrand: String? = "visa",
        readerId: String? = "reader-1"
    ) -> PaymentTransaction {
        PaymentTransaction(
            id: id,
            customerId: customerId,
            amount: amount,
            currency: currency,
            status: status,
            createdAt: createdAt,
            syncStatus: syncStatus,
            cardToken: cardToken,
            idempotencyKey: idempotencyKey,
            cardLast4: cardLast4,
            cardBrand: cardBrand,
            readerId: readerId
        )
    }
}
