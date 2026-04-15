import Foundation
import SwiftData

/// Local persistence for `PaymentTransaction`. Amount is stored as a string for exact `Decimal` round-trip.
@Model
final class PaymentTransactionRecord {
    @Attribute(.unique) var id: String
    var customerId: String
    var amountStorage: String
    var currency: String
    var statusRaw: String
    var createdAt: Date
    var syncStatusRaw: String
    var cardToken: String
    var idempotencyKey: String
    var cardLast4: String?
    var cardBrand: String?
    var readerId: String?

    init(
        id: String,
        customerId: String,
        amountStorage: String,
        currency: String,
        statusRaw: String,
        createdAt: Date,
        syncStatusRaw: String,
        cardToken: String,
        idempotencyKey: String,
        cardLast4: String?,
        cardBrand: String?,
        readerId: String?
    ) {
        self.id = id
        self.customerId = customerId
        self.amountStorage = amountStorage
        self.currency = currency
        self.statusRaw = statusRaw
        self.createdAt = createdAt
        self.syncStatusRaw = syncStatusRaw
        self.cardToken = cardToken
        self.idempotencyKey = idempotencyKey
        self.cardLast4 = cardLast4
        self.cardBrand = cardBrand
        self.readerId = readerId
    }
}

// MARK: - Domain mapping

extension PaymentTransactionRecord {
    private static let decimalLocale = Locale(identifier: "en_US_POSIX")

    /// Maps a domain payment into a new SwiftData record (insert path).
    static func make(from domain: PaymentTransaction) -> PaymentTransactionRecord {
        PaymentTransactionRecord(
            id: domain.id,
            customerId: domain.customerId,
            amountStorage: NSDecimalNumber(decimal: domain.amount).stringValue,
            currency: domain.currency,
            statusRaw: domain.status.rawValue,
            createdAt: domain.createdAt,
            syncStatusRaw: domain.syncStatus.rawValue,
            cardToken: domain.cardToken,
            idempotencyKey: domain.idempotencyKey,
            cardLast4: domain.cardLast4,
            cardBrand: domain.cardBrand,
            readerId: domain.readerId
        )
    }

    /// Updates an existing row from domain (upsert / future sync-friendly).
    func apply(_ domain: PaymentTransaction) {
        customerId = domain.customerId
        amountStorage = NSDecimalNumber(decimal: domain.amount).stringValue
        currency = domain.currency
        statusRaw = domain.status.rawValue
        createdAt = domain.createdAt
        syncStatusRaw = domain.syncStatus.rawValue
        cardToken = domain.cardToken
        idempotencyKey = domain.idempotencyKey
        cardLast4 = domain.cardLast4
        cardBrand = domain.cardBrand
        readerId = domain.readerId
    }

    func toDomain() -> PaymentTransaction? {
        guard let amount = Decimal(string: amountStorage, locale: Self.decimalLocale) else {
            return nil
        }
        guard let status = TransactionStatus(rawValue: statusRaw) else { return nil }
        guard let syncStatus = SyncStatus(rawValue: syncStatusRaw) else { return nil }
        return PaymentTransaction(
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
