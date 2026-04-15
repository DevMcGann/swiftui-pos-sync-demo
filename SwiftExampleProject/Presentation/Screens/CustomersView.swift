import SwiftUI

struct CustomersView: View {
    @Bindable var viewModel: CustomersViewModel
    var onLogout: (() -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if showFullScreenLoading {
                    ProgressView("Loading customers…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if showErrorEmpty {
                    ContentUnavailableView {
                        Label("Couldn’t load customers", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(viewModel.errorMessage ?? "")
                    } actions: {
                        Button("Try again") {
                            Task { await viewModel.load() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if showNoCustomersYet {
                    ContentUnavailableView(
                        "No customers",
                        systemImage: "person.3",
                        description: Text("Pull down or use the button to refresh.")
                    )
                } else {
                    List {
                        if let message = viewModel.errorMessage {
                            Section {
                                Text(message)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }
                        ForEach(viewModel.customers, id: \.id) { customer in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(customer.name)
                                    .font(.headline)
                                Text(customer.email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
            .navigationTitle("Customers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.isRemoteRefreshing && !viewModel.customers.isEmpty {
                                ProgressView()
                            }
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(viewModel.isRemoteRefreshing)
                }
                if let onLogout {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out", action: onLogout)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var showFullScreenLoading: Bool {
        viewModel.customers.isEmpty
            && viewModel.errorMessage == nil
            && (viewModel.isRemoteRefreshing || viewModel.isAwaitingFirstRemote)
    }

    private var showErrorEmpty: Bool {
        viewModel.customers.isEmpty
            && viewModel.errorMessage != nil
            && !viewModel.isRemoteRefreshing
    }

    private var showNoCustomersYet: Bool {
        viewModel.customers.isEmpty
            && viewModel.errorMessage == nil
            && !viewModel.isRemoteRefreshing
            && !viewModel.isAwaitingFirstRemote
    }
}
