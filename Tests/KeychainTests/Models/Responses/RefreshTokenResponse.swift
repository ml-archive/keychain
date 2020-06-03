import Vapor

struct RefreshTokenResponse: Content {
    let refreshToken: String
}
