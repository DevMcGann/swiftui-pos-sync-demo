import Foundation

actor StubCustomerRepository: CustomerRepository {
    func fetchCustomers() async throws -> [Customer] {
        throw DataLayerError.notImplemented
    }

    func getLocalCustomers() async -> [Customer] {
        []
    }
}
