import Foundation

enum KeychainSessionStoreError: Error, Equatable, Sendable {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
    case unexpectedData
}
