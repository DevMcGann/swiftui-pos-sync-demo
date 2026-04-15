import Foundation

struct LoadPendingPaymentsUseCase {
    private let paymentRepository: PaymentRepository

    init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    func execute() async -> [PaymentTransaction] {
        await paymentRepository.getPendingTransactions()
    }
}
