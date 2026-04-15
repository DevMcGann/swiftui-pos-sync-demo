import Observation

@MainActor
@Observable
final class SessionRootViewModel {
    private(set) var session: UserSession?
    private(set) var isRestoringSession = true
    private(set) var logoutErrorMessage: String?

    private let restoreSessionUseCase: RestoreSessionUseCase
    private let logoutUseCase: LogoutUseCase

    init(
        restoreSessionUseCase: RestoreSessionUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.restoreSessionUseCase = restoreSessionUseCase
        self.logoutUseCase = logoutUseCase
    }

    func restoreSessionIfNeeded() async {
        isRestoringSession = true
        session = await restoreSessionUseCase.execute()
        isRestoringSession = false
    }

    func applySignedIn(_ newSession: UserSession) {
        session = newSession
    }

    func logout() async {
        logoutErrorMessage = nil
        do {
            try await logoutUseCase.execute()
            session = nil
        } catch {
            logoutErrorMessage = "Could not sign out. Please try again."
        }
    }
}
