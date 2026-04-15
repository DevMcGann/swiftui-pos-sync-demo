protocol CustomerRepository {
    func fetchCustomers() async throws -> [Customer]
    func getLocalCustomers() async -> [Customer]
}
