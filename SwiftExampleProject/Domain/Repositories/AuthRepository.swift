protocol AuthRepository {
    func login(email: String, password: String) async throws -> UserSession
    func logout() async throws
    func getCurrentSession() async -> UserSession?
}
