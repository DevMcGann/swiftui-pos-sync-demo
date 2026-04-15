struct StartReaderScanningUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute() async {
        await cardReaderService.startScanning()
    }
}
