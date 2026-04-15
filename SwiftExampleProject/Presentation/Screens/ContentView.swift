//
//  ContentView.swift
//  SwiftExampleProject
//
//  Created by Gabriel Mc Gann on 13/04/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var onLogout: (() -> Void)?

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TemplateItemsViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete { viewModel.deleteItems(at: $0) }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { viewModel.addItem() }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                if let onLogout {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out", action: onLogout)
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            viewModel.attach(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
