import Foundation

enum APIClientError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case transportError(URLError)
}
