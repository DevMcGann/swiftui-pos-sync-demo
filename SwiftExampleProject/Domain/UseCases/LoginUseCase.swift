struct LoginUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> UserSession {
        let trimmedEmail = Self.trimWhitespace(email)
        guard !trimmedEmail.isEmpty else { throw AuthLoginError.emptyEmail }
        guard !password.isEmpty else { throw AuthLoginError.emptyPassword }
        guard Self.isPlausibleEmail(trimmedEmail) else { throw AuthLoginError.invalidEmail }

        return try await authRepository.login(email: trimmedEmail, password: password)
    }

    private static func trimWhitespace(_ s: String) -> String {
        guard !s.isEmpty else { return s }
        var start = s.startIndex
        var end = s.endIndex
        while start < end, s[start].isWhitespace {
            s.formIndex(after: &start)
        }
        while start < end {
            let beforeEnd = s.index(before: end)
            guard s[beforeEnd].isWhitespace else { break }
            end = beforeEnd
        }
        return String(s[start..<end])
    }

    private static func isPlausibleEmail(_ email: String) -> Bool {
        guard let at = email.firstIndex(of: "@") else { return false }
        let local = email[..<at]
        let domainStart = email.index(after: at)
        guard domainStart < email.endIndex else { return false }
        let domain = email[domainStart...]
        if local.isEmpty || domain.isEmpty { return false }
        if domain.contains("@") { return false }
        return domain.contains(".")
    }
}
