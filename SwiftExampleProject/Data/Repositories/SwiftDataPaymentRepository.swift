import Foundation
import SwiftData

@MainActor
final class SwiftDataPaymentRepository: PaymentRepository {
    private let store: PaymentSwiftDataStore

    init(context: ModelContext) {
        self.store = PaymentSwiftDataStore(context: context)
    }

    func savePaymentDraft(_ transaction: PaymentTransaction) async throws {
        try store.upsert(transaction)
    }

    func fetchPayment(id: String) async -> PaymentTransaction? {
        try? store.fetchPayment(id: id)
    }

    func fetchReadyForSync() async -> [PaymentTransaction] {
        (try? store.fetchReadyForSync()) ?? []
    }

    func fetchFailedSyncPayments() async -> [PaymentTransaction] {
        (try? store.fetchFailedSyncPayments()) ?? []
    }

    func getTransactions() async -> [PaymentTransaction] {
        (try? store.fetchAllSortedByDateDescending()) ?? []
    }

    func getPendingTransactions() async -> [PaymentTransaction] {
        (try? store.fetchPendingSortedByDateDescending()) ?? []
    }
}
