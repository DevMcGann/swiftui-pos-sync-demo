enum PaymentSyncError: Error, Equatable {
    case paymentNotFound
    case invalidStateForEnqueue

    var userFacingMessage: String {
        switch self {
        case .paymentNotFound:
            return "That payment could not be found."
        case .invalidStateForEnqueue:
            return "Only a saved card-read draft can be queued for sync."
        }
    }
}
