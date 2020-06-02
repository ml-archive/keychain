import JWT
import Vapor

public protocol KeychainPayload: JWTPayload {
    associatedtype User

    init(expirationDate: Date, user: User) throws
    func findUser(request: Request) -> EventLoopFuture<User>
}
