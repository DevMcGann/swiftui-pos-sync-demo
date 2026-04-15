import Foundation

/// Small URLSession wrapper for typed errors and consistent response handling. Inject `URLSession` in tests.
struct HTTPClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Performs the request and returns body + response for successful HTTP status codes (2xx).
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIClientError.transportError(error)
        } catch {
            throw APIClientError.transportError(URLError(.unknown))
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw APIClientError.httpError(statusCode: http.statusCode)
        }
        return (data, http)
    }
}
