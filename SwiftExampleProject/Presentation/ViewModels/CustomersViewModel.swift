import Foundation
import Observation

@MainActor
@Observable
final class CustomersViewModel {
    private(set) var customers: [Customer] = []
    private(set) var isRemoteRefreshing = false
    private(set) var isAwaitingFirstRemote = true
    private(set) var errorMessage: String?

    private let loadLocalCustomersUseCase: LoadLocalCustomersUseCase
    private let refreshCustomersUseCase: RefreshCustomersUseCase

    init(
        loadLocalCustomersUseCase: LoadLocalCustomersUseCase,
        refreshCustomersUseCase: RefreshCustomersUseCase
    ) {
        self.loadLocalCustomersUseCase = loadLocalCustomersUseCase
        self.refreshCustomersUseCase = refreshCustomersUseCase
    }

    /// Loads cached customers first, then refreshes from the network. Keeps local rows if refresh fails.
    func load() async {
        isAwaitingFirstRemote = true
        errorMessage = nil

        customers = await loadLocalCustomersUseCase.execute()

        isRemoteRefreshing = true
        defer {
            isRemoteRefreshing = false
            isAwaitingFirstRemote = false
        }

        do {
            customers = try await refreshCustomersUseCase.execute()
            errorMessage = nil
        } catch let error as CustomerDataError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = CustomerDataError.unknown.userFacingMessage
        }
    }
}
