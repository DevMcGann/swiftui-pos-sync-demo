/// Transport-agnostic submission of a payment already persisted locally.
/// Agent 2 implements this with URLSession (or mocks); failures are transport/API errors, not validation.
protocol PaymentSyncGateway: Sendable {
    func submitPayment(_ transaction: PaymentTransaction) async throws
}
