import Sugar
import Vapor

extension JWTKeychainUser: PublicRepresentable {
    public struct Public: Content {
        let email: String
        let name: String
    }

    public func convertToPublic(on req: Request) throws -> Future<Public> {
        return req.future(.init(email: email, name: name))
    }
}
