protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
    func getLocalProducts() async -> [Product]
}
