import Routing

public struct JWTKeychainEndpoints {
    public let login: String
    public let me: String
    public let register: String
    public let token: String
    public let update: String

    /// Endpoints to use by provider when registering routes.
    ///
    /// - Parameters:
    ///   - login: login endpoint (POST)
    ///   - me: me endpoint (GET)
    ///   - register: register endpoint (POST)
    ///   - token: token refresh endpoint (POST)
    ///   - update: user update endpoint (PATCH)
    public init(
        login: String,
        me: String,
        register: String,
        token: String,
        update: String
    ) {
        self.login = login
        self.me = me
        self.register = register
        self.token = token
        self.update = update
    }

    public static var `default`: JWTKeychainEndpoints {
        let users = "users"
        return .init(
            login: users + "/login",
            me: users + "/me",
            register: users,
            token: users + "/token",
            update: users + "/me"
        )
    }
}
