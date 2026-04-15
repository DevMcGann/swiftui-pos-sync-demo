import Observation

@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let loginUseCase: LoginUseCase
    private let sessionRoot: SessionRootViewModel

    init(loginUseCase: LoginUseCase, sessionRoot: SessionRootViewModel) {
        self.loginUseCase = loginUseCase
        self.sessionRoot = sessionRoot
    }

    func login() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let session = try await loginUseCase.execute(email: email, password: password)
            sessionRoot.applySignedIn(session)
            password = ""
        } catch let error as AuthLoginError {
            errorMessage = Self.userFacingMessage(for: error)
        } catch {
            errorMessage = Self.genericErrorMessage
        }
    }

    private static let genericErrorMessage = "Something went wrong. Please try again."

    private static func userFacingMessage(for error: AuthLoginError) -> String {
        switch error {
        case .emptyEmail: "Enter your email."
        case .emptyPassword: "Enter your password."
        case .invalidEmail: "Enter a valid email address."
        }
    }
}
