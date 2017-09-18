import JWTProvider
import Vapor

public struct TokenGenerators {
    internal let apiAccess: ExpireableSigner
    internal let refresh: ExpireableSigner?
    internal let resetPassword: ExpireableSigner
}

extension TokenGenerators {
    public var apiAccessTokenGenerator: ExpireableSigner {
        return apiAccess
    }

    public var refreshTokenGenerator: ExpireableSigner? {
        return refresh
    }

    public var resetPasswordTokenGenerator: ExpireableSigner {
        return resetPassword
    }
}

extension TokenGenerators {
    public init(settings: Settings, signerMap: SignerMap) throws {
        apiAccess = try ExpireableSigner(
            signerParameters: settings.apiAccess,
            signerMap: signerMap
        )

        if let refreshToken = settings.refreshToken {
            refresh = try ExpireableSigner(
                signerParameters: refreshToken,
                signerMap: signerMap
            )
        } else {
            refresh = nil
        }

        resetPassword = try ExpireableSigner(
            signerParameters: settings.resetPassword,
            signerMap: signerMap
        )
    }
}


// MARK: Helper

public extension TokenGenerators {
    public func makeResponse<U: JWTKeychainUser>(
        for user: U,
        withOptions responseOptions: ResponseOptions
    ) throws -> ResponseRepresentable {
        var response = JSON()

        if responseOptions.contains(.access) {
            try response.set(
                "accessToken",
                self
                    .apiAccessTokenGenerator
                    .generateToken(for: user)
                    .string
            )
        }
        if
            responseOptions.contains(.refresh),
            let refreshTokenGenerator = self.refreshTokenGenerator
        {
            try response.set(
                "refreshToken",
                refreshTokenGenerator.generateToken(for: user).string
            )
        }
        if responseOptions.contains(.user) {
            if responseOptions == [.user] {
                // make an exception when only user is to be returned
                // -> return user as root level object
                return try user.makeJSON()
            } else {
                try response.set("user", user)
            }
        }

        return response
    }
}

public struct ResponseOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: ResponseOptions.RawValue) {
        self.rawValue = rawValue
    }

    public static let access = ResponseOptions(rawValue: 1 << 0)
    public static let refresh = ResponseOptions(rawValue: 1 << 1)
    public static let user = ResponseOptions(rawValue: 1 << 2)

    public static let all: ResponseOptions = [.access, .refresh, .user]
}
