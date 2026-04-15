enum TransactionStatus: String, Equatable, Sendable {
    case draft
    case cardRead
    case pendingSync
    case synced
    case failed
}
