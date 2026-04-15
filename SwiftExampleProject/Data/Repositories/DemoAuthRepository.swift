import Foundation

/// Demo auth only: no network. Persists session in Keychain for restore across launches.
actor DemoAuthRepository: AuthRepository {
    private let keychain: KeychainSessionStore
    private var memorySession: UserSession?

    init(keychain: KeychainSessionStore = KeychainSessionStore()) {
        self.keychain = keychain
    }

    func login(email _: String, password _: String) async throws -> UserSession {
        let session = UserSession(
            id: UUID().uuidString,
            token: "demo.\(UUID().uuidString)",
            isLoggedIn: true
        )
        try keychain.save(session: session)
        memorySession = session
        return session
    }

    func logout() async throws {
        memorySession = nil
        try keychain.clear()
    }

    func getCurrentSession() async -> UserSession? {
        if let memorySession {
            return memorySession
        }
        do {
            let restored = try keychain.readSession()
            memorySession = restored
            return restored
        } catch {
            return nil
        }
    }
}
