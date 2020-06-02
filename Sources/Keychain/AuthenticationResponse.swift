import Vapor

public struct AuthenticationResponse<User> {
    public let user: User
    public let accessToken: String
    public let refreshToken: String

    public init(
        user: User,
        accessToken: String,
        refreshToken: String
    ) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    public func map<T>(_ transformUser: (User) throws -> T) rethrows -> AuthenticationResponse<T> {
        .init(user: try transformUser(user), accessToken: accessToken, refreshToken: refreshToken)
    }

    public func flatMap<T>(
        _ transformUser: (User) -> EventLoopFuture<T>
    ) -> EventLoopFuture<AuthenticationResponse<T>> {
        transformUser(user).map {
            .init(user: $0, accessToken: self.accessToken, refreshToken: self.refreshToken)
        }
    }
}

extension AuthenticationResponse: Codable where User: Codable {}
extension AuthenticationResponse: Content, RequestDecodable, ResponseEncodable where User: Content {}
