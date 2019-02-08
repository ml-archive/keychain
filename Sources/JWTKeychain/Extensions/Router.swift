import Vapor

public extension Router {
    func useJWTKeychainRoutes<U: JWTKeychainUserType>(
        _ type: U.Type,
        on container: Container
    ) throws {
        let config: JWTKeychainConfig<U> = try container.make()
        let middlewares: JWTKeychainMiddlewares<U> = try container.make()
        let access = self.grouped(middlewares.accessMiddlewares)

        if let registerPath = config.endpoints.register {
            self.post(registerPath, use: config.controller.register)
        }

        if let loginPath = config.endpoints.login {
            self.post(loginPath, use: config.controller.logIn)
        }

        if let mePath = config.endpoints.me {
            access.get(mePath, use: config.controller.me)
        }

        if let updatePath = config.endpoints.update {
            access.patch(updatePath, use: config.controller.update)
        }

        if
            let refreshMiddlewares = middlewares.refreshMiddlewares,
            let tokenPath = config.endpoints.token
        {
            self.grouped(refreshMiddlewares).post(tokenPath, use: config.controller.token)
        }
    }
}
