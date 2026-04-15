import Foundation
import Testing
@testable import SwiftExampleProject

struct PaymentSyncUseCasesTests {
    // MARK: - EnqueuePaymentForSyncUseCase

    @Test
    func enqueue_validCardReadPending_transitionsToPendingSync() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction()
        try await repo.savePaymentDraft(payment)

        try await EnqueuePaymentForSyncUseCase(paymentRepository: repo).execute(paymentId: payment.id)

        let updated = await repo.fetchPayment(id: payment.id)
        #expect(updated?.status == .pendingSync)
        #expect(updated?.syncStatus == .pending)
    }

    @Test
    func enqueue_wrongStatus_throwsInvalidState() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction(status: .draft, syncStatus: .pending)
        try await repo.savePaymentDraft(payment)

        await #expect(throws: PaymentSyncError.invalidStateForEnqueue) {
            try await EnqueuePaymentForSyncUseCase(paymentRepository: repo).execute(paymentId: payment.id)
        }
    }

    @Test
    func enqueue_wrongSyncStatus_throwsInvalidState() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction(status: .cardRead, syncStatus: .syncing)
        try await repo.savePaymentDraft(payment)

        await #expect(throws: PaymentSyncError.invalidStateForEnqueue) {
            try await EnqueuePaymentForSyncUseCase(paymentRepository: repo).execute(paymentId: payment.id)
        }
    }

    @Test
    func enqueue_missingPayment_throwsNotFound() async throws {
        let repo = StubPaymentRepository()
        await #expect(throws: PaymentSyncError.paymentNotFound) {
            try await EnqueuePaymentForSyncUseCase(paymentRepository: repo).execute(paymentId: "nope")
        }
    }

    // MARK: - ProcessPendingPaymentsUseCase

    @Test
    func processPending_submitsOnlyOldestReadyInFIFOOrder() async throws {
        let repo = StubPaymentRepository()
        let older = PaymentTestFixtures.transaction(
            id: "a",
            createdAt: Date(timeIntervalSince1970: 100),
            syncStatus: .pending,
            idempotencyKey: "idem-a"
        ).updating(status: .pendingSync)
        let newer = PaymentTestFixtures.transaction(
            id: "b",
            createdAt: Date(timeIntervalSince1970: 200),
            syncStatus: .pending,
            idempotencyKey: "idem-b"
        ).updating(status: .pendingSync)
        try await repo.savePaymentDraft(newer)
        try await repo.savePaymentDraft(older)

        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        let useCase = ProcessPendingPaymentsUseCase(paymentRepository: repo, syncGateway: gateway)

        try await useCase.execute()

        let first = await repo.fetchPayment(id: "a")
        let second = await repo.fetchPayment(id: "b")
        #expect(first?.status == .synced)
        #expect(first?.syncStatus == .synced)
        #expect(second?.status == .pendingSync)
        #expect(second?.syncStatus == .pending)
    }

    @Test
    func processPending_marksSyncedOnGatewaySuccess() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction(idempotencyKey: "ok-key").updating(status: .pendingSync)
        try await repo.savePaymentDraft(payment)

        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        try await ProcessPendingPaymentsUseCase(paymentRepository: repo, syncGateway: gateway).execute()

        let updated = await repo.fetchPayment(id: payment.id)
        #expect(updated?.status == .synced)
        #expect(updated?.syncStatus == .synced)
    }

    @Test
    func processPending_passesSyncingPaymentToGateway() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction().updating(status: .pendingSync)
        try await repo.savePaymentDraft(payment)

        let gateway = ExpectSyncingBeforeSubmitGateway()
        try await ProcessPendingPaymentsUseCase(paymentRepository: repo, syncGateway: gateway).execute()
    }

    @Test
    func processPending_marksFailedOnGatewayError() async throws {
        let repo = StubPaymentRepository()
        let payment = PaymentTestFixtures.transaction(idempotencyKey: "ok-no-fail").updating(status: .pendingSync)
        try await repo.savePaymentDraft(payment)

        let gateway = ThrowingPaymentSyncGateway()

        await #expect(throws: PaymentSyncTransportError.simulatedFailure) {
            try await ProcessPendingPaymentsUseCase(paymentRepository: repo, syncGateway: gateway).execute()
        }

        let updated = await repo.fetchPayment(id: payment.id)
        #expect(updated?.status == .failed)
        #expect(updated?.syncStatus == .failed)
    }

    @Test
    func processPending_emptyQueue_doesNothing() async throws {
        let repo = StubPaymentRepository()
        let gateway = MockPaymentSyncGateway(
            firstSubmitDelayNanoseconds: 0,
            idempotentHitDelayNanoseconds: 0
        )
        try await ProcessPendingPaymentsUseCase(paymentRepository: repo, syncGateway: gateway).execute()
    }

    // MARK: - RetryFailedPaymentsUseCase

    @Test
    func retryFailed_restoresPendingSyncAndPending() async throws {
        let repo = StubPaymentRepository()
        let p1 = PaymentTestFixtures.transaction(id: "1").updating(status: .failed, syncStatus: .failed)
        let p2 = PaymentTestFixtures.transaction(id: "2").updating(status: .failed, syncStatus: .failed)
        try await repo.savePaymentDraft(p1)
        try await repo.savePaymentDraft(p2)

        try await RetryFailedPaymentsUseCase(paymentRepository: repo).execute()

        let one = await repo.fetchPayment(id: "1")
        let two = await repo.fetchPayment(id: "2")
        #expect(one?.status == .pendingSync)
        #expect(one?.syncStatus == .pending)
        #expect(two?.status == .pendingSync)
        #expect(two?.syncStatus == .pending)
    }
}

// MARK: - Test doubles

private struct ExpectSyncingBeforeSubmitGateway: PaymentSyncGateway {
    func submitPayment(_ transaction: PaymentTransaction) async throws {
        guard transaction.syncStatus == .syncing else {
            throw ExpectSyncingGatewayError.notSyncing
        }
    }
}

private enum ExpectSyncingGatewayError: Error {
    case notSyncing
}

private struct ThrowingPaymentSyncGateway: PaymentSyncGateway {
    func submitPayment(_ transaction: PaymentTransaction) async throws {
        throw PaymentSyncTransportError.simulatedFailure
    }
}
