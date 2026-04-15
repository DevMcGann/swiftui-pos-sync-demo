import Foundation

/// Simulated BLE-style reader for demos: same contract as a future `CoreBluetooth` implementation.
actor MockCardReaderService: CardReaderService {
    private var connectionState: ReaderConnectionState = .disconnected
    private var connectedDevice: ReaderDevice?

    private var connectionObservers: [UUID: AsyncStream<ReaderConnectionState>.Continuation] = [:]
    private var cardReadObservers: [UUID: AsyncStream<CardReadResult>.Continuation] = [:]

    private let connectDelayNanoseconds: UInt64

    init(connectDelayNanoseconds: UInt64 = 450_000_000) {
        self.connectDelayNanoseconds = connectDelayNanoseconds
    }

    nonisolated func observeConnectionState() -> AsyncStream<ReaderConnectionState> {
        AsyncStream(bufferingPolicy: .bufferingOldest(32)) { continuation in
            let id = UUID()
            Task { await self.registerConnectionObserver(id: id, continuation: continuation) }
        }
    }

    nonisolated func observeCardReads() -> AsyncStream<CardReadResult> {
        AsyncStream(bufferingPolicy: .bufferingOldest(32)) { continuation in
            let id = UUID()
            Task { await self.registerCardReadObserver(id: id, continuation: continuation) }
        }
    }

    func startScanning() async {
        switch connectionState {
        case .connected, .connecting:
            await disconnect()
        case .scanning:
            emitConnection(.scanning)
            return
        case .disconnected, .failed:
            break
        }
        connectedDevice = nil
        emitConnection(.scanning)
    }

    func connect(to device: ReaderDevice) async throws {
        guard connectionState == .scanning else {
            throw CardReaderActionError.cannotConnectInCurrentState
        }
        connectedDevice = device
        emitConnection(.connecting)

        try await Task.sleep(nanoseconds: connectDelayNanoseconds)

        guard connectionState == .connecting else {
            connectedDevice = nil
            return
        }
        emitConnection(.connected)
    }

    func disconnect() async {
        connectedDevice = nil
        emitConnection(.disconnected)
    }

    func simulateCardRead() async throws {
        guard connectionState == .connected, let device = connectedDevice else {
            throw CardReaderActionError.notReadyToRead
        }

        let result = CardReadResult(
            token: "mock_tok_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12))",
            brand: "Visa",
            last4: "4242",
            entryMode: .contactless,
            readerId: device.id
        )
        emitCardRead(result)
    }

    // MARK: - Observers

    private func registerConnectionObserver(
        id: UUID,
        continuation: AsyncStream<ReaderConnectionState>.Continuation
    ) {
        connectionObservers[id] = continuation
        continuation.yield(connectionState)
        continuation.onTermination = { [id] _ in
            Task { await self.removeConnectionObserver(id: id) }
        }
    }

    private func registerCardReadObserver(
        id: UUID,
        continuation: AsyncStream<CardReadResult>.Continuation
    ) {
        cardReadObservers[id] = continuation
        continuation.onTermination = { [id] _ in
            Task { await self.removeCardReadObserver(id: id) }
        }
    }

    private func removeConnectionObserver(id: UUID) {
        connectionObservers[id] = nil
    }

    private func removeCardReadObserver(id: UUID) {
        cardReadObservers[id] = nil
    }

    private func emitConnection(_ state: ReaderConnectionState) {
        connectionState = state
        for continuation in connectionObservers.values {
            continuation.yield(state)
        }
    }

    private func emitCardRead(_ result: CardReadResult) {
        for continuation in cardReadObservers.values {
            continuation.yield(result)
        }
    }
}
