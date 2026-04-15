import SwiftUI
import SwiftData

struct LoginView: View {
    @Bindable var viewModel: LoginViewModel

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button {
                    Task { await viewModel.login() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        Text(viewModel.isLoading ? "Signing in…" : "Sign In")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LoginPreviewHost()
}

private struct LoginPreviewHost: View {
    private let sessionRoot: SessionRootViewModel
    private let loginViewModel: LoginViewModel

    init() {
        let schema = Schema([Item.self, CustomerRecord.self, PaymentTransactionRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        let c = AppDependencyContainer(modelContext: modelContainer.mainContext)
        let sr = SessionRootViewModel(
            restoreSessionUseCase: c.makeRestoreSessionUseCase(),
            logoutUseCase: c.makeLogoutUseCase()
        )
        self.sessionRoot = sr
        self.loginViewModel = LoginViewModel(
            loginUseCase: c.makeLoginUseCase(),
            sessionRoot: sr
        )
    }

    var body: some View {
        NavigationStack {
            LoginView(viewModel: loginViewModel)
        }
    }
}
