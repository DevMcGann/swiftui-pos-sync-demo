import Foundation
import SwiftData
import Testing
@testable import SwiftExampleProject

@MainActor
struct SwiftDataPaymentRepositoryTests {
    @Test
    func saveDraft_fetchAllAndPending_andReadyForSync() async throws {
        let schema = Schema([PaymentTransactionRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let repo = SwiftDataPaymentRepository(context: context)

        let draft = PaymentTestFixtures.transaction(status: .cardRead, syncStatus: .pending)
        try await repo.savePaymentDraft(draft)

        let all = await repo.getTransactions()
        let pending = await repo.getPendingTransactions()
        #expect(all.count == 1)
        #expect(all.first?.id == draft.id)
        #expect(pending.count == 1)

        let readyBeforeEnqueue = await repo.fetchReadyForSync()
        #expect(readyBeforeEnqueue.isEmpty)

        let queued = draft.updating(status: .pendingSync)
        try await repo.savePaymentDraft(queued)

        let ready = await repo.fetchReadyForSync()
        #expect(ready.count == 1)
        #expect(ready.first?.id == draft.id)
    }
}
