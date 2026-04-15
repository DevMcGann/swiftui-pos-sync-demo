enum PaymentDraftError: Error, Equatable {
    case emptyCustomerId
    case invalidAmount
    case emptyCurrency

    var userFacingMessage: String {
        switch self {
        case .emptyCustomerId:
            return "Select a customer."
        case .invalidAmount:
            return "Enter a valid amount greater than zero."
        case .emptyCurrency:
            return "Enter a currency code (for example USD)."
        }
    }
}
