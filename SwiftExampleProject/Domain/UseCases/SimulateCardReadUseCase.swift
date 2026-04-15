struct SimulateCardReadUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute() async throws {
        try await cardReaderService.simulateCardRead()
    }
}
