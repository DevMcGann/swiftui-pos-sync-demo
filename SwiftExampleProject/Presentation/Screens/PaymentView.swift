import SwiftUI

struct PaymentView: View {
    @Bindable var viewModel: PaymentViewModel
    var onLogout: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section("Customer") {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Picker("Customer", selection: $viewModel.selectedCustomerId) {
                            ForEach(viewModel.customerChoices, id: \.id) { customer in
                                Text(customer.name).tag(customer.id)
                            }
                        }
                        if viewModel.customers.isEmpty {
                            Text("No customers in cache — using walk-in demo. Refresh customers on the Customers tab to load your list.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Amount") {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                    TextField("Currency", text: $viewModel.currencyCode)
                        .textInputAutocapitalization(.characters)
                }

                Section("Card read") {
                    if let summary = viewModel.latestCardReadSummary {
                        Text(summary)
                            .font(.footnote.monospaced())
                            .textSelection(.enabled)
                    } else {
                        Text("No card read yet. Use the Reader tab to connect and simulate a card read.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let err = viewModel.errorMessage {
                    Section {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if let ok = viewModel.successMessage {
                    Section {
                        Text(ok)
                            .font(.footnote)
                            .foregroundStyle(.green)
                    }
                }

                Section {
                    Button {
                        Task { await viewModel.createPayment() }
                    } label: {
                        HStack {
                            if viewModel.isCreating {
                                ProgressView()
                            }
                            Text(viewModel.isCreating ? "Saving…" : "Create payment draft")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.canCreatePayment || viewModel.isCreating)
                }

                Section {
                    Text("Ready to sync: \(viewModel.readyForSyncCount) · Failed: \(viewModel.failedSyncCount)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        Task { await viewModel.processNextPendingSync() }
                    } label: {
                        HStack {
                            if viewModel.isSyncBusy {
                                ProgressView()
                            }
                            Text("Sync next payment")
                        }
                    }
                    .disabled(viewModel.readyForSyncCount == 0 || viewModel.isSyncBusy || viewModel.enqueueingPaymentId != nil)

                    Button {
                        Task { await viewModel.processAllPendingSync() }
                    } label: {
                        Text("Sync all queued")
                    }
                    .disabled(viewModel.readyForSyncCount == 0 || viewModel.isSyncBusy || viewModel.enqueueingPaymentId != nil)

                    Button {
                        Task { await viewModel.retryFailedPayments() }
                    } label: {
                        Text("Retry failed payments")
                    }
                    .disabled(viewModel.failedSyncCount == 0 || viewModel.isSyncBusy || viewModel.enqueueingPaymentId != nil)
                } header: {
                    Text("Outbox / sync")
                } footer: {
                    Text("Queue drafts with “Enqueue”, then sync one at a time or drain the queue. Retry resets failed rows to the queue.")
                        .font(.footnote)
                }

                Section("Payments") {
                    if viewModel.payments.isEmpty {
                        Text("No payments yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.payments, id: \.id) { payment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(payment.amount.description) \(payment.currency)")
                                    .font(.headline)
                                Text(viewModel.syncSummary(for: payment))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Customer \(payment.customerId)")
                                    .font(.caption)
                                Text(payment.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)

                                if viewModel.canEnqueueForSync(payment) {
                                    Button {
                                        Task { await viewModel.enqueueForSync(paymentId: payment.id) }
                                    } label: {
                                        HStack {
                                            if viewModel.enqueueingPaymentId == payment.id {
                                                ProgressView()
                                            }
                                            Text("Enqueue for sync")
                                        }
                                    }
                                    .disabled(viewModel.enqueueingPaymentId != nil || viewModel.isSyncBusy)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("New payment")
            .toolbar {
                if let onLogout {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out", action: onLogout)
                    }
                }
            }
            .task {
                await viewModel.loadScreenData()
            }
        }
    }
}
