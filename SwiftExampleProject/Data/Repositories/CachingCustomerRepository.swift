import Foundation

/// Fetches from the network, persists to SwiftData, and serves reads from the local cache.
@MainActor
final class CachingCustomerRepository: CustomerRepository {
    private let remote: RemoteCustomerAPI
    private let localStore: CustomerSwiftDataStore

    init(
        remote: RemoteCustomerAPI = RemoteCustomerAPI(),
        localStore: CustomerSwiftDataStore
    ) {
        self.remote = remote
        self.localStore = localStore
    }

    func fetchCustomers() async throws -> [Customer] {
        do {
            let fresh = try await remote.fetchCustomers()
            try localStore.replaceAll(with: fresh)
            return fresh
        } catch let error as CustomerDataError {
            throw error
        } catch {
            if let api = error as? APIClientError {
                throw CustomerDataError(apiClientError: api)
            }
            throw CustomerDataError.unknown
        }
    }

    func getLocalCustomers() async -> [Customer] {
        do {
            return try localStore.fetchAll()
        } catch {
            return []
        }
    }
}
