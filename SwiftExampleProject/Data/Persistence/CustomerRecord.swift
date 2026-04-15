import Foundation
import SwiftData

@Model
final class CustomerRecord {
    @Attribute(.unique) var id: String
    var name: String
    var email: String

    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

extension CustomerRecord {
    func toDomain() -> Customer {
        Customer(id: id, name: name, email: email)
    }
}
