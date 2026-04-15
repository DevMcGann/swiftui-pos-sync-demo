protocol CardReaderService {
    func observeConnectionState() -> AsyncStream<ReaderConnectionState>
    func observeCardReads() -> AsyncStream<CardReadResult>
    func startScanning() async
    func connect(to device: ReaderDevice) async throws
    func disconnect() async
    func simulateCardRead() async throws
}
