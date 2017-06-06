import Authentication
import Fluent
import JWT
import Vapor

extension Token {
    init<E: Entity>(user: E, expirationDate: Date?, signer: Signer) throws {
        guard
            let id = user.id,
            let idAsString = id.int.map(String.init) ?? id.string,
            let expirationDate = expirationDate else {
                throw Abort.serverError
        }

        let expirationTime = ExpirationTimeClaim(date: expirationDate)
        let subject = SubjectClaim(string: idAsString)

        let jwt = try JWT(
            payload: JSON([expirationTime, subject]),
            signer: signer
        )

        self.init(string: try jwt.createToken())
    }
}
