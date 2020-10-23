import Vapor

public extension Router {
    func useJWTKeychainRoutes<U: JWTKeychainUserType>(
        _ type: U.Type,
        on container: Container
    ) throws {
        let config: JWTKeychainConfig<U> = try container.make()
        let controller = config.controller
        let middlewares: JWTKeychainMiddlewares<U> = try container.make()
        let access = self.grouped(middlewares.accessMiddlewares)

        if let registerPath = config.endpoints.register {
            self.post(registerPath) { req in try controller.register(req: req) }
        }

        if let loginPath = config.endpoints.login {
            self.post(loginPath) { req in try controller.logIn(req: req) }
        }

        if let mePath = config.endpoints.me {
            access.get(mePath) { req in try controller.me(req: req) }
        }

        if let updatePath = config.endpoints.update {
            access.patch(updatePath) { req in try controller.update(req: req) }
        }

        if
            let refreshMiddlewares = middlewares.refreshMiddlewares,
            let tokenPath = config.endpoints.token
        {
            self.grouped(refreshMiddlewares).post(tokenPath) { req in try config.controller.token(req: req) }
        }
    }
}
