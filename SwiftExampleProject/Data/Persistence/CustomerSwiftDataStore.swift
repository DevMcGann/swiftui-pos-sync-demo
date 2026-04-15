import Foundation
import SwiftData

/// Local customer persistence. Stays on the main actor with `ModelContext` (SwiftData requirement).
@MainActor
final class CustomerSwiftDataStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Customer] {
        var descriptor = FetchDescriptor<CustomerRecord>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        let records = try context.fetch(descriptor)
        return records.map { $0.toDomain() }
    }

    /// Replaces the cached list with a fresh remote snapshot (offline-first: only call after a successful fetch).
    func replaceAll(with customers: [Customer]) throws {
        let existing = try context.fetch(FetchDescriptor<CustomerRecord>())
        for record in existing {
            context.delete(record)
        }
        for customer in customers {
            context.insert(
                CustomerRecord(id: customer.id, name: customer.name, email: customer.email)
            )
        }
        try context.save()
    }
}
