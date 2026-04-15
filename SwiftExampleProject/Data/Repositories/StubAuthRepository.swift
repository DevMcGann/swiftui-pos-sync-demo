import Foundation

actor StubAuthRepository: AuthRepository {
    private var session: UserSession?

    func login(email _: String, password _: String) async throws -> UserSession {
        throw DataLayerError.notImplemented
    }

    func logout() async throws {
        session = nil
    }

    func getCurrentSession() async -> UserSession? {
        session
    }
}
