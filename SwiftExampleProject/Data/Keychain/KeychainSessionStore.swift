import Foundation
import Security

/// Persists a minimal session snapshot for restore after launch. Domain types stay unaware of encoding and Keychain details.
struct KeychainSessionStore: Sendable {
    private let service: String
    private let account: String

    init(
        service: String = Bundle.main.bundleIdentifier ?? "SwiftExampleProject.session",
        account: String = "current_user_session"
    ) {
        self.service = service
        self.account = account
    }

    func save(session: UserSession) throws {
        let payload = PersistedSession(userId: session.id, token: session.token)
        let data = try JSONEncoder().encode(payload)
        try deleteExistingItem()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainSessionStoreError.saveFailed(status)
        }
    }

    func readSession() throws -> UserSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw KeychainSessionStoreError.readFailed(status)
        }
        guard let data = item as? Data else {
            throw KeychainSessionStoreError.unexpectedData
        }
        let payload = try JSONDecoder().decode(PersistedSession.self, from: data)
        return UserSession(id: payload.userId, token: payload.token, isLoggedIn: true)
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainSessionStoreError.deleteFailed(status)
        }
    }

    private func deleteExistingItem() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainSessionStoreError.deleteFailed(status)
        }
    }
}

private struct PersistedSession: Codable, Equatable, Sendable {
    let userId: String
    let token: String
}
