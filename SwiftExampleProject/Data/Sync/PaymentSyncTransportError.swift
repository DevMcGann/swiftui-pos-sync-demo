import Foundation

/// Data-layer errors from mock/real sync transport (not domain `PaymentSyncError`).
enum PaymentSyncTransportError: Error, Equatable, Sendable {
    case simulatedFailure
}
