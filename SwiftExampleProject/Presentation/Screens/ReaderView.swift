import SwiftUI

struct ReaderView: View {
    @Bindable var viewModel: ReaderViewModel
    var onLogout: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section("Reader status") {
                    LabeledContent("State", value: viewModel.connectionStatusTitle)
                }

                Section("Demo device") {
                    LabeledContent("Name", value: viewModel.demoDevice.name)
                    LabeledContent("ID", value: viewModel.demoDevice.id)
                }

                if let message = viewModel.actionErrorMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("Last card read") {
                    if let summary = viewModel.lastReadSummary {
                        Text(summary)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                    } else {
                        Text("No card read yet.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Actions") {
                    Button("Start scanning") {
                        Task { await viewModel.startScanning() }
                    }

                    Button("Connect to demo reader") {
                        Task { await viewModel.connectDemoDevice() }
                    }
                    .disabled(!viewModel.isConnectEnabled)

                    Button("Disconnect", role: .destructive) {
                        Task { await viewModel.disconnect() }
                    }
                    .disabled(!viewModel.isDisconnectEnabled)

                    Button("Simulate card read") {
                        Task { await viewModel.simulateCardRead() }
                    }
                    .disabled(!viewModel.isSimulateCardReadEnabled)
                }
            }
            .navigationTitle("Card reader")
            .toolbar {
                if let onLogout {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out", action: onLogout)
                    }
                }
            }
        }
    }
}
