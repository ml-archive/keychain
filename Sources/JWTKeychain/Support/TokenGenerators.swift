import JWTProvider

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
    init(settings: Settings, signerMap: SignerMap) throws {
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
