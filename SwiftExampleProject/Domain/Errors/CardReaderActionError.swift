import Foundation

/// Failures from reader control actions, safe to surface in the presentation layer.
enum CardReaderActionError: Error, Equatable, Sendable {
    case notReadyToRead
    case cannotConnectInCurrentState

    var userFacingMessage: String {
        switch self {
        case .notReadyToRead:
            return "Connect to the reader before simulating a card read."
        case .cannotConnectInCurrentState:
            return "Start scanning, then connect to the demo reader."
        }
    }
}
