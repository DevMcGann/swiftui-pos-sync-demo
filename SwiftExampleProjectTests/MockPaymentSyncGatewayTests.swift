import Foundation
import Testing
@testable import SwiftExampleProject

struct MockPaymentSyncGatewayTests {
    @Test
    func sameIdempotencyKey_secondSubmitIsNoOpAndSucceeds() async throws {
        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        let key = "stable-idem-key"
        let tx = PaymentTestFixtures.transaction(idempotencyKey: key)

        try await gateway.submitPayment(tx)
        try await gateway.submitPayment(tx)
    }

    @Test
    func idempotencyKeyContainingFail_throwsSimulatedFailure() async throws {
        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        let tx = PaymentTestFixtures.transaction(idempotencyKey: "will-FAIL-now")

        await #expect(throws: PaymentSyncTransportError.simulatedFailure) {
            try await gateway.submitPayment(tx)
        }
    }

    @Test
    func failedSubmit_doesNotMarkKeyCompleted_retryAfterKeyChangeCanSucceed() async throws {
        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        let bad = PaymentTestFixtures.transaction(id: "p1", idempotencyKey: "x-fail-x")
        await #expect(throws: PaymentSyncTransportError.simulatedFailure) {
            try await gateway.submitPayment(bad)
        }

        let good = PaymentTestFixtures.transaction(id: "p2", idempotencyKey: "success-key")
        try await gateway.submitPayment(good)
    }
}
