struct LoadLocalCustomersUseCase {
    private let customerRepository: CustomerRepository

    init(customerRepository: CustomerRepository) {
        self.customerRepository = customerRepository
    }

    func execute() async -> [Customer] {
        await customerRepository.getLocalCustomers()
    }
}
