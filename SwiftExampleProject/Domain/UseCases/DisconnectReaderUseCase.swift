struct DisconnectReaderUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute() async {
        await cardReaderService.disconnect()
    }
}
