struct RefreshCustomersUseCase {
    private let customerRepository: CustomerRepository

    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }

    func execute() async throws -> [Customer] {
        try await customerRepository.fetchCustomers()
    }
}
