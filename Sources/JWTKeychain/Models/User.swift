import Authentication
import FluentProvider
import JWT
import JWTProvider
import SMTP

/// A lightweight User implementation to get started with JWTKeychain.
public final class User: Model, SoftDeletable, Timestampable {

    public struct Keys {
        static let email = "email"
        static let name = "name"
        static let hashedPassword = "hashedPassword"

        static let password = "password"
        static let passwordRepeat = "passwordRepeat"
        static let oldPassword = "oldPassword"
    }

    public var email: String
    public var name: String
    public var hashedPassword: String?

    public let storage = Storage()

    public init(
        email: String,
        name: String,
        hashedPassword: String?
    ) {
        self.email = email
        self.name = name
        self.hashedPassword = hashedPassword
    }
}

// MARK: EmailAddressRepresentable

extension User: EmailAddressRepresentable {
    public var emailAddress: EmailAddress {
        return EmailAddress(name: name, address: email)
    }
}

// MARK: JSONRepresentable

extension User: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set(User.idKey, id)
        try json.set(Keys.email, email)
        try json.set(Keys.name, name)

        return json
    }
}

// MARK: JWTKeychainAuthenticatable

extension User: JWTKeychainAuthenticatable {
    public static func make(request: Request) throws -> User {
        guard let json = request.json else {
            throw JWTKeychainUserError.missingJSONOnRequest
        }

        guard let email: String = json[Keys.email]?.string else {
            throw JWTKeychainUserError.missingEmail
        }

        guard let name: String = json[Keys.name]?.string else {
            throw JWTKeychainUserError.missingName
        }

        guard let password: String = json[Keys.password]?.string else {
            throw JWTKeychainUserError.missingPassword
        }

        guard try makeQuery()
            .filter(Keys.email.string, email)
            .count() == 0
            else {
                throw JWTKeychainUserError.userWithGivenEmailAlreadyExists
        }

        return User(
            email: email,
            name: name,
            hashedPassword: try hash(password: password)
        )
    }
}

// MARK: NodeRepresentable

extension User: NodeRepresentable {}

// MARK: PasswordAuthenticatable

extension User: PasswordAuthenticatable {
    public static var passwordVerifier: PasswordVerifier? {
        return bCryptHasher
    }
}

// MARK: PasswordResettable

extension User: PasswordResettable {
    public static func extractPasswordResetInfo(
        from request: Request,
        isOptional: Bool
    ) throws -> PasswordResetInfoType {
        guard let json = request.json else {
            throw JWTKeychainUserError.missingJSONOnRequest
        }

        return PasswordResetForm(
            email: try json.get(Keys.email),
            password: try json.get(Keys.password),
            isOptional: isOptional
        )
    }
}

// MARK: PasswordUpdateable

extension User: PasswordUpdateable {
    public func updatePassword(to newPassword: String) throws {
        try update(password: newPassword)
    }
}

// MARK: PayloadAuthenticatable

extension User: PayloadAuthenticatable {
    public struct UserIdentifier: JSONInitializable {
        let id: Identifier

        public init(json: JSON) throws {
            id = Identifier(try json.get(SubjectClaim.name) as Node)
        }
    }

    public typealias PayloadType = UserIdentifier

    public static func authenticate(
        _ payload: PayloadType
        ) throws -> User {
        guard let user = try User.find(payload.id) else {
            throw Abort.notFound
        }

        return user
    }
}

// MARK: Preparation

extension User: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string(Keys.email, unique: true)
            $0.string(Keys.name)
            $0.string(Keys.hashedPassword, optional: true)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: RequestUpdateable

extension User: RequestUpdateable {
    public func update(request: Request) throws {
        guard let json = request.json else {
            throw JWTKeychainUserError.missingJSONOnRequest
        }
        
        let name = json[Keys.name]?.string
        let email = json[Keys.email]?.string
        let password = try extractNewPassword(json: json)
        
        if
            let email = email,
            email != self.email,
            let id = id?.string
        {
            // require old password as confirmation when updating email
            try verifyOldPassword(json: json)
            
            let numberOfExistingUsersWithSameEmail = try makeQuery()
                .filter(Keys.email, email)
                .filter(idKey, .notEquals, id)
                .count()
            
            if numberOfExistingUsersWithSameEmail > 0 {
                throw JWTKeychainUserError.userWithGivenEmailAlreadyExists
            }
        }

        try update(
            email: email,
            name: name,
            password: password
        )
    }

    private func extractNewPassword(json: JSON) throws -> String? {
        guard let password = json[Keys.password]?.string else {
            return nil
        }

        guard password == json[Keys.passwordRepeat]?.string else {
            throw JWTKeychainUserError.passwordsDoNotMatch
        }

        // require old password as confirmation when updating password
        try verifyOldPassword(json: json)

        return password
    }

    private func verifyOldPassword(json: JSON) throws {
        guard
            let oldPassword = json[Keys.oldPassword]?.string,
            let hashedPassword = hashedPassword,
            let passwordVerifier = User.passwordVerifier,
            try passwordVerifier.verify(
                password: oldPassword.makeBytes(),
                matches: hashedPassword.makeBytes()
            )
            else {
                throw JWTKeychainUserError.missingOldPassword
        }
    }
}

// MARK: RowRepresentable

extension User: RowRepresentable {
    public convenience init(row: Row) throws {
        try self.init(
            email: row.get(Keys.email),
            name: row.get(Keys.name),
            hashedPassword: row.get(Keys.hashedPassword)
        )
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set(Keys.email, email)
        try row.set(Keys.name, name)
        try row.set(Keys.hashedPassword, hashedPassword)

        return row
    }
}

// MARK: Helper

extension User {
    fileprivate func update(
        email: String? = nil,
        name: String? = nil,
        password: String? = nil
    ) throws {
        if let email = email {
            self.email = email
        }

        if let name = name {
            self.name = name
        }

        if let password = password {
            self.hashedPassword = try User.hash(password: password)
        }
    }

    fileprivate static func hash(password: String) throws -> String {
        return try bCryptHasher
            .make(password)
            .makeString()
    }
}
