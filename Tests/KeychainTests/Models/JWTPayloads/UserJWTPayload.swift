import Foundation
import JWT
import Keychain
import Vapor

struct UserJWTPayload: KeychainPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    init(expirationDate: Date, user: User) {
        self.exp = .init(value: expirationDate)
        self.sub = .init(value: user.id)
    }

    func findUser(request: Request) -> EventLoopFuture<User> {
        request.eventLoop.future(request.testUser).unwrap(or: TestError.userNotFound)
    }

    func verify(using signer: JWTSigner) throws {
        // don't verify anything since we're not testing the JWT package itself
    }
}
