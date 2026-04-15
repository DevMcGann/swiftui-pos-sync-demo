enum ReaderConnectionState: Equatable, Sendable {
    case disconnected
    case scanning
    case connecting
    case connected
    case failed
}
