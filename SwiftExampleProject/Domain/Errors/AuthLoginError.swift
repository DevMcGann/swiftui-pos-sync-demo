enum AuthLoginError: Error, Equatable {
    case emptyEmail
    case emptyPassword
    case invalidEmail
}
