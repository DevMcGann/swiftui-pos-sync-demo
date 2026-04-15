struct UserSession: Equatable, Sendable {
    let id: String
    let token: String
    let isLoggedIn: Bool
}
