import Foundation

struct LoadAllPaymentsUseCase {
    private let paymentRepository: PaymentRepository

    init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    func execute() async -> [PaymentTransaction] {
        await paymentRepository.getTransactions()
    }
}
