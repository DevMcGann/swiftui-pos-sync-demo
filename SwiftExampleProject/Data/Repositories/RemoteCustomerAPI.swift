import Foundation

/// Remote-only JSONPlaceholder `/users` fetch. Composed by `CachingCustomerRepository`.
actor RemoteCustomerAPI {
    private let http: HTTPClient
    private let usersListURL: URL
    private let decoder: JSONDecoder

    init(
        http: HTTPClient = HTTPClient(),
        usersListURL: URL = RemoteCustomerAPI.defaultUsersURL,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.http = http
        self.usersListURL = usersListURL
        self.decoder = decoder
    }

    func fetchCustomers() async throws -> [Customer] {
        var request = URLRequest(url: usersListURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await http.data(for: request)

        do {
            let dtos = try decoder.decode([JSONPlaceholderUserDTO].self, from: data)
            return dtos.map { $0.toDomain() }
        } catch {
            throw APIClientError.decodingFailed
        }
    }

    fileprivate static let defaultUsersURL = URL(string: "https://jsonplaceholder.typicode.com/users")!
}
