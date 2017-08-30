import Authentication
import Fluent
import JWT
import Vapor

extension Token {
    init<E: Entity>(
        user: E,
        expirationDate: Date,
        signer: Signer
    ) throws where E: PasswordAuthenticatable {
        let claims: [Claim] = try [
            ExpirationTimeClaim(date: expirationDate),
            SubjectClaim(user: user),
            PasswordClaim(user: user)
        ]

        let jwt = try JWT(
            payload: JSON(claims),
            signer: signer
        )

        self.init(string: try jwt.createToken())
    }
}

// MARK: Helper

extension SubjectClaim {
    fileprivate init(user: Entity) throws {
        guard
            let id = user.id,
            let string = id.string ?? id.int.map(String.init) else {
                throw Abort.serverError
        }

        self.init(string: string)
    }
}
