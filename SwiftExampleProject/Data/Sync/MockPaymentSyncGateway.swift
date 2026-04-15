import Foundation

/// Simulated payment submission: uses `idempotencyKey` in the logical payload and supports idempotent success.
/// Demo rule: if the key contains `"fail"` (any casing), submission throws `PaymentSyncTransportError.simulatedFailure`.
final class MockPaymentSyncGateway: PaymentSyncGateway, @unchecked Sendable {
    private let lock = NSLock()
    private var completedIdempotencyKeys: Set<String> = []
    private let firstSubmitDelayNanoseconds: UInt64
    private let idempotentHitDelayNanoseconds: UInt64

    init(
        firstSubmitDelayNanoseconds: UInt64 = 350_000_000,
        idempotentHitDelayNanoseconds: UInt64 = 80_000_000
    ) {
        self.firstSubmitDelayNanoseconds = firstSubmitDelayNanoseconds
        self.idempotentHitDelayNanoseconds = idempotentHitDelayNanoseconds
    }

    func submitPayment(_ transaction: PaymentTransaction) async throws {
        let key = transaction.idempotencyKey

        lock.lock()
        let alreadySynced = completedIdempotencyKeys.contains(key)
        lock.unlock()

        if alreadySynced {
            try await Task.sleep(nanoseconds: idempotentHitDelayNanoseconds)
            return
        }

        try await Task.sleep(nanoseconds: firstSubmitDelayNanoseconds)

        let payloadSummary =
            "idempotencyKey=\(key)|paymentId=\(transaction.id)|amount=\(transaction.amount)|currency=\(transaction.currency)"
        _ = payloadSummary

        if key.localizedStandardContains("fail") {
            throw PaymentSyncTransportError.simulatedFailure
        }

        lock.lock()
        completedIdempotencyKeys.insert(key)
        lock.unlock()
    }
}
