struct ObserveReaderConnectionUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute() -> AsyncStream<ReaderConnectionState> {
        cardReaderService.observeConnectionState()
    }
}
