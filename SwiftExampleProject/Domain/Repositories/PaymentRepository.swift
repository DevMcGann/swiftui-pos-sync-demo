import Foundation

protocol PaymentRepository {
    func savePaymentDraft(_ transaction: PaymentTransaction) async throws
    func fetchPayment(id: String) async -> PaymentTransaction?
    func fetchReadyForSync() async -> [PaymentTransaction]
    func fetchFailedSyncPayments() async -> [PaymentTransaction]
    func getTransactions() async -> [PaymentTransaction]
    func getPendingTransactions() async -> [PaymentTransaction]
}
