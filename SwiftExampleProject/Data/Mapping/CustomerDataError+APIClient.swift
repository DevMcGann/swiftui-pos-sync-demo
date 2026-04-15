import Foundation

extension CustomerDataError {
    init(apiClientError: APIClientError) {
        switch apiClientError {
        case .transportError(let underlying):
            if underlying.code == .notConnectedToInternet {
                self = .offlineOrUnreachable
            } else {
                self = .offlineOrUnreachable
            }
        case .httpError:
            self = .serverError
        case .decodingFailed, .invalidResponse:
            self = .invalidPayload
        case .invalidURL:
            self = .unknown
        }
    }
}
