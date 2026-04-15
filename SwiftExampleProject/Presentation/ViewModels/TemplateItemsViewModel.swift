import Observation
import SwiftData
import SwiftUI

/// Template shell: loads `Item` rows and applies edits via `ModelContext`.
@Observable
final class TemplateItemsViewModel {
    private(set) var items: [Item] = []
    private var modelContext: ModelContext?

    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
    }

    func addItem() {
        guard let modelContext else { return }
        withAnimation {
            modelContext.insert(Item(timestamp: Date()))
        }
        reload()
    }

    func deleteItems(at offsets: IndexSet) {
        guard let modelContext else { return }
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
        reload()
    }

    private func reload() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.timestamp)])
        items = (try? modelContext.fetch(descriptor)) ?? []
    }
}
