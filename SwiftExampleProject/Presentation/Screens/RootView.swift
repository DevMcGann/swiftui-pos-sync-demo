import SwiftUI

struct RootView: View {
    private let container: AppDependencyContainer
    @State private var sessionRoot: SessionRootViewModel
    @State private var loginViewModel: LoginViewModel
    @State private var customersViewModel: CustomersViewModel
    @State private var readerViewModel: ReaderViewModel
    @State private var paymentViewModel: PaymentViewModel

    init(container: AppDependencyContainer) {
        self.container = container
        let sr = SessionRootViewModel(
            restoreSessionUseCase: container.makeRestoreSessionUseCase(),
            logoutUseCase: container.makeLogoutUseCase()
        )
        _sessionRoot = State(initialValue: sr)
        _loginViewModel = State(
            initialValue: LoginViewModel(
                loginUseCase: container.makeLoginUseCase(),
                sessionRoot: sr
            )
        )
        _customersViewModel = State(
            initialValue: CustomersViewModel(
                loadLocalCustomersUseCase: container.makeLoadLocalCustomersUseCase(),
                refreshCustomersUseCase: container.makeRefreshCustomersUseCase()
            )
        )
        _readerViewModel = State(
            initialValue: ReaderViewModel(
                observeConnectionUseCase: container.makeObserveReaderConnectionUseCase(),
                observeCardReadsUseCase: container.makeObserveCardReadsUseCase(),
                startScanningUseCase: container.makeStartReaderScanningUseCase(),
                connectUseCase: container.makeConnectReaderDeviceUseCase(),
                disconnectUseCase: container.makeDisconnectReaderUseCase(),
                simulateCardReadUseCase: container.makeSimulateCardReadUseCase()
            )
        )
        _paymentViewModel = State(
            initialValue: PaymentViewModel(
                createPaymentDraftUseCase: container.makeCreatePaymentDraftUseCase(),
                loadLocalCustomersUseCase: container.makeLoadLocalCustomersUseCase(),
                loadAllPaymentsUseCase: container.makeLoadAllPaymentsUseCase(),
                enqueuePaymentForSyncUseCase: container.makeEnqueuePaymentForSyncUseCase(),
                processPendingPaymentsUseCase: container.makeProcessPendingPaymentsUseCase(),
                paymentSyncBatchRunner: container.makePaymentSyncBatchRunner(),
                retryFailedPaymentsUseCase: container.makeRetryFailedPaymentsUseCase(),
                observeCardReadsUseCase: container.makeObserveCardReadsUseCase()
            )
        )
    }

    var body: some View {
        Group {
            if sessionRoot.isRestoringSession {
                ProgressView("Loading…")
            } else if sessionRoot.session != nil {
                VStack(alignment: .leading, spacing: 8) {
                    if let message = sessionRoot.logoutErrorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    TabView {
                        CustomersView(
                            viewModel: customersViewModel,
                            onLogout: {
                                Task { await sessionRoot.logout() }
                            }
                        )
                        .tabItem {
                            Label("Customers", systemImage: "person.3")
                        }

                        ReaderView(
                            viewModel: readerViewModel,
                            onLogout: {
                                Task { await sessionRoot.logout() }
                            }
                        )
                        .tabItem {
                            Label("Reader", systemImage: "sensor.tag.radiowaves.forward")
                        }

                        PaymentView(
                            viewModel: paymentViewModel,
                            onLogout: {
                                Task { await sessionRoot.logout() }
                            }
                        )
                        .tabItem {
                            Label("Payment", systemImage: "creditcard")
                        }
                    }
                }
            } else {
                NavigationStack {
                    LoginView(viewModel: loginViewModel)
                }
            }
        }
        .task {
            await sessionRoot.restoreSessionIfNeeded()
        }
    }
}
