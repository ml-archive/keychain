@testable import JWTKeychain
import Authentication
import JWT
import SMTP
import Vapor

final class TestUser {
    let email: String
    let token: Token

    init(email: String, token: Token) {
        self.email = email
        self.token = token
    }
}

extension TestUser: Equatable {
    static func ==(lhs: TestUser, rhs: TestUser) -> Bool {
        return lhs.email == rhs.email && lhs.token.string == rhs.token.string
    }
}

extension TestUser: EmailAddressRepresentable {
    var emailAddress: EmailAddress {
        return EmailAddress(address: email)
    }
}

extension TestUser: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("email", email)
        return json
    }
}

extension TestUser: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return Node(try makeJSON())
    }
}

extension TestUser: TokenCreating {
    func createToken(using signer: Signer) throws -> Token {
        return try Token(string: signer.sign(message: token.string.makeBytes()).makeString())
    }
}
