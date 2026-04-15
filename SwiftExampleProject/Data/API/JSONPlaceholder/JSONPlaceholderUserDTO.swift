import Foundation

/// Subset of https://jsonplaceholder.typicode.com/users — only fields needed for `Customer`.
struct JSONPlaceholderUserDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let email: String
}

extension JSONPlaceholderUserDTO {
    func toDomain() -> Customer {
        Customer(id: String(id), name: name, email: email)
    }
}
