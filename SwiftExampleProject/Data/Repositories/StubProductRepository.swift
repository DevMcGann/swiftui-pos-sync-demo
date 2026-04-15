import Foundation

actor StubProductRepository: ProductRepository {
    func fetchProducts() async throws -> [Product] {
        throw DataLayerError.notImplemented
    }

    func getLocalProducts() async -> [Product] {
        []
    }
}
