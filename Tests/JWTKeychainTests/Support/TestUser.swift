@testable import JWTKeychain
import Authentication
import Fluent
import JWT
import SMTP
import Vapor

final class TestUser {
    let email: String
    let token: Token
    let hashedPassword: String?
    let storage = Storage()

    init(email: String, hashedPassword: String?, token: Token) {
        self.email = email
        self.hashedPassword = hashedPassword
        self.token = token
        self.id = 1
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

extension TestUser: PasswordAuthenticatable {
    static func authenticate(_ creds: Authentication.Password) throws -> TestUser {
        return TestUser(
            email: creds.username,
            hashedPassword: creds.password,
            token: Token(string: "token")
        )
    }
}

extension TestUser: Entity {
    func makeRow() throws -> Row {
        return Row()
    }

    convenience init(row: Row) throws {
        self.init(
            email: "email",
            hashedPassword: "hashedpassword",
            token: Token(string: "token")
        )
    }
}
