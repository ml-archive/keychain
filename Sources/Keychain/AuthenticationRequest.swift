import Vapor

public protocol AuthenticationRequest {
    typealias User = AccessKeychainConfig.JWTPayload.User

    associatedtype AccessKeychainConfig: KeychainConfig
    associatedtype RefreshKeychainConfig: KeychainConfig
        where RefreshKeychainConfig.JWTPayload.User == User
}

public extension AuthenticationRequest {
    static func authenticationResponse(
        for user: User,
        on request: Request,
        currentDate: Date = Date()
    ) throws -> AuthenticationResponse<User> {
        try .init(
            user: user,
            accessToken: AccessKeychainConfig
                .makeToken(for: user, on: request, currentDate: currentDate),
            refreshToken: RefreshKeychainConfig
                .makeToken(for: user, on: request, currentDate: currentDate)
        )
    }
}
