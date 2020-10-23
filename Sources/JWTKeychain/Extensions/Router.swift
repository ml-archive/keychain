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
            self.post(registerPath) { req in config.controller.register(req) }
        }

        if let loginPath = config.endpoints.login {
            self.post(loginPath) { req in config.controller.logIn(req) }
        }

        if let mePath = config.endpoints.me {
            access.get(mePath) { req in config.controller.me(req) }
        }

        if let updatePath = config.endpoints.update {
            access.patch(updatePath) { req in config.controller.update }
        }

        if
            let refreshMiddlewares = middlewares.refreshMiddlewares,
            let tokenPath = config.endpoints.token
        {
            self.grouped(refreshMiddlewares).post(tokenPath) { req in config.controller.token }
        }
    }
}
