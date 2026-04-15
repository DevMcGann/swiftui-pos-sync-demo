struct ConnectReaderDeviceUseCase {
    private let cardReaderService: CardReaderService

    init(cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
    }

    func execute(device: ReaderDevice) async throws {
        try await cardReaderService.connect(to: device)
    }
}
