import Foundation

actor StubPaymentRepository: PaymentRepository {
    private var transactions: [PaymentTransaction] = []

    func savePaymentDraft(_ transaction: PaymentTransaction) async throws {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        } else {
            transactions.append(transaction)
        }
    }

    func fetchPayment(id: String) async -> PaymentTransaction? {
        transactions.first { $0.id == id }
    }

    func fetchReadyForSync() async -> [PaymentTransaction] {
        transactions
            .filter { $0.status == .pendingSync && $0.syncStatus == .pending }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func fetchFailedSyncPayments() async -> [PaymentTransaction] {
        transactions
            .filter { $0.syncStatus == .failed }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func getTransactions() async -> [PaymentTransaction] {
        transactions.sorted { $0.createdAt > $1.createdAt }
    }

    func getPendingTransactions() async -> [PaymentTransaction] {
        transactions.filter { $0.syncStatus != .synced }
    }
}
