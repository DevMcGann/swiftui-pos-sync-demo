struct RestoreSessionUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async -> UserSession? {
        await authRepository.getCurrentSession()
    }
}
