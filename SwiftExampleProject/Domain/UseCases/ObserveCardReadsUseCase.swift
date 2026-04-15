struct ObserveCardReadsUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute() -> AsyncStream<CardReadResult> {
        cardReaderService.observeCardReads()
    }
}
