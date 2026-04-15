struct CardReadResult: Equatable, Sendable {
    let token: String
    let brand: String
    let last4: String
    let entryMode: CardEntryMode
    let readerId: String
}
