import Routing

public struct JWTKeychainEndpoints {
    public let login                : PathComponentsRepresentable
    public let me                   : PathComponentsRepresentable
    public let register             : PathComponentsRepresentable
    public let requestPasswordReset : PathComponentsRepresentable
    public let token                : PathComponentsRepresentable
    public let update               : PathComponentsRepresentable

    /// Endpoints to use by provider when registering routes.
    ///
    /// - Parameters:
    ///   - login                   : login endpoint (POST)
    ///   - me                      : me endpoint (GET)
    ///   - register                : register endpoint (POST)
    ///   - requestPasswordReset    : request password reset endpoint (POST)
    ///   - token                   : token refresh endpoint (POST)
    ///   - update                  : user update endpoint (PATCH)
    public init(
        login                   : PathComponentsRepresentable,
        me                      : PathComponentsRepresentable,
        register                : PathComponentsRepresentable,
        requestPasswordReset    : PathComponentsRepresentable,
        token                   : PathComponentsRepresentable,
        update                  : PathComponentsRepresentable
    ) {
        self.login                  = login
        self.me                     = me
        self.register               = register
        self.requestPasswordReset   = requestPasswordReset
        self.token                  = token
        self.update                 = update
    }

    public static var `default`: JWTKeychainEndpoints {
        let users = "users"
        return .init(
            login                   : users + "/login",
            me                      : users + "/me",
            register                : users,
            requestPasswordReset    : users + "/reset-password/request",
            token                   : users + "/token",
            update                  : users + "/me"
        )
    }
}
