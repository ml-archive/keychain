import Vapor

public protocol ForgotPasswordRequest: ValidatableRequest {
    associatedtype Config: KeychainConfig

    static func sendToken(
        _ token: String,
        user: Config.JWTPayload.User,
        config: Config,
        request: Request
    ) -> EventLoopFuture<Void>

    func findUser(request: Request) -> EventLoopFuture<Config.JWTPayload.User?>
}

public extension ForgotPasswordRequest {
    static func sendToken(on request: Request, currentDate: Date = Date()) -> EventLoopFuture<Void> {
        validated(on: request)
            .flatMap { $0.findUser(request: request) }
            .flatMap { user in
                guard let user = user else {
                    // when no user could be found, skip the steps below but pretend that the
                    // request was successful
                    return request.eventLoop.future()
                }
                let config = request.keychain.config(for: Config.self)
                do {
                    return sendToken(
                        try config.makeToken(for: user, on: request, currentDate: currentDate),
                        user: user,
                        config: config,
                        request: request
                    )
                } catch {
                    return request.eventLoop.makeFailedFuture(error)
                }
            }
    }
}
