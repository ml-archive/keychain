import Vapor

public struct UserResponse<U: PublicRepresentable>: Content {
    let user: U.Public?
    let accessToken: String?
    let refreshToken: String?

    public init(user: U.Public?, accessToken: String? = nil, refreshToken: String? = nil) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct UserResponseOptions: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int

    public static let user = UserResponseOptions(rawValue: 1 << 0)
    public static let accessToken = UserResponseOptions(rawValue: 1 << 1)
    public static let refreshToken = UserResponseOptions(rawValue: 1 << 2)

    public static let all: UserResponseOptions = [.user, .accessToken, .refreshToken]
}
