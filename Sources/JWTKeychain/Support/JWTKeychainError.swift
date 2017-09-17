public enum JWTKeychainError: Error {
    case missingSigner(kid: String)
}
