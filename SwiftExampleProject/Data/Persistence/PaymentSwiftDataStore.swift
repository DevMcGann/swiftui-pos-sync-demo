import Foundation
import SwiftData

/// Payment CRUD on the main `ModelContext`. Phase 7 can extend this with outbox writes without changing the domain API.
@MainActor
final class PaymentSwiftDataStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func upsert(_ transaction: PaymentTransaction) throws {
        let tid = transaction.id
        let predicate = #Predicate<PaymentTransactionRecord> { $0.id == tid }
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(predicate: predicate)
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            existing.apply(transaction)
        } else {
            context.insert(PaymentTransactionRecord.make(from: transaction))
        }
        try context.save()
    }

    func fetchAllSortedByDateDescending() throws -> [PaymentTransaction] {
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let records = try context.fetch(descriptor)
        return records.compactMap { $0.toDomain() }
    }

    /// Rows whose `syncStatus` is not `.synced` (pending local / outbox candidates for Phase 7).
    func fetchPendingSortedByDateDescending() throws -> [PaymentTransaction] {
        let syncedRaw = SyncStatus.synced.rawValue
        let predicate = #Predicate<PaymentTransactionRecord> { $0.syncStatusRaw != syncedRaw }
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let records = try context.fetch(descriptor)
        return records.compactMap { $0.toDomain() }
    }

    func fetchPayment(id: String) throws -> PaymentTransaction? {
        let tid = id
        let predicate = #Predicate<PaymentTransactionRecord> { $0.id == tid }
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return nil }
        return record.toDomain()
    }

    func fetchReadyForSync() throws -> [PaymentTransaction] {
        let statusQueued = TransactionStatus.pendingSync.rawValue
        let syncPending = SyncStatus.pending.rawValue
        let predicate = #Predicate<PaymentTransactionRecord> {
            $0.statusRaw == statusQueued && $0.syncStatusRaw == syncPending
        }
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let records = try context.fetch(descriptor)
        return records.compactMap { $0.toDomain() }
    }

    func fetchFailedSyncPayments() throws -> [PaymentTransaction] {
        let syncFailed = SyncStatus.failed.rawValue
        let predicate = #Predicate<PaymentTransactionRecord> { $0.syncStatusRaw == syncFailed }
        var descriptor = FetchDescriptor<PaymentTransactionRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let records = try context.fetch(descriptor)
        return records.compactMap { $0.toDomain() }
    }
}
