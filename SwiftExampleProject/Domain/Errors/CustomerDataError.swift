import Foundation

/// Domain-facing customer fetch failures. Safe for presentation mapping without depending on transport types.
enum CustomerDataError: Error, Equatable, Sendable {
    case offlineOrUnreachable
    case serverError
    case invalidPayload
    case unknown

    var userFacingMessage: String {
        switch self {
        case .offlineOrUnreachable:
            return "No internet connection. Try again when you’re online."
        case .serverError:
            return "The server returned an error. Please try again."
        case .invalidPayload:
            return "Couldn’t read the customer list. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
