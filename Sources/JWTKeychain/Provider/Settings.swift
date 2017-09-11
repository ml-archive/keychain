import SMTP
import Vapor

public struct Settings {
    public let baseURL: String
    public let emailViewPath: String

    public let fromEmailAddress: EmailAddress

    public let apiAccess: SignerParameters
    public let refreshToken: SignerParameters?
    public let resetPassword: SignerParameters

    /**
     - parameter baseURL: base URL of the app; used for password reset link.
     - parameter emailViewPath: path to view used to render password reset email
     html.
     - parameter fromEmailAddress: sender
     - parameter apiPathPrefix: path prefix for api routes
     - parameter frontendPathPrefix: path prefix for frontend routes
     - parameter apiAccess: signer parameters for API access routes.
     Defaults to "kid": "access" and a 1 hour expiration period
     - parameter refreshToken: signer parameters for refresh token route.
     Defaults to "kid": "refresh" and a 1 year expiration period.
     - parameter resetPassword: signer parameters for reset password link.
     Defaults to "kid": "reset" and a 1 hour expiration period.
     */
    public init(
        baseURL: String,
        emailViewPath: String?,
        fromEmailAddress: EmailAddress,
        apiAccess: SignerParameters?,
        refreshToken: SignerParameters?,
        resetPassword: SignerParameters?
    ) {
        self.baseURL = baseURL
        self.emailViewPath = emailViewPath ?? "Emails/resetPassword"
        self.fromEmailAddress = fromEmailAddress
        self.apiAccess = apiAccess ??
            SignerParameters(kid: "access", expireIn: 1.hour)
        self.refreshToken = refreshToken
        self.resetPassword = resetPassword ??
            SignerParameters(kid: "reset", expireIn: 1.hour)
    }
}

extension Settings: ConfigInitializable {
    public init(config: Config) throws {
        guard let baseURL = config["app", "url"]?.string else {
            throw ConfigError.missing(
                key: ["url"],
                file: "app",
                desiredType: String.self
            )
        }

        let keychainConfigFile = "jwt-keychain"
        guard let keychainConfig = config[keychainConfigFile] else {
            throw ConfigError.missingFile(keychainConfigFile)
        }

        guard let fromName = keychainConfig["resetPassword", "fromName"]?
            .string else {
                throw ConfigError.missing(
                    key: ["resetPassword", "fromName"],
                    file: keychainConfigFile,
                    desiredType: String.self
                )
        }

        guard let fromAddress = keychainConfig["resetPassword", "fromAddress"]?
            .string else {
                throw ConfigError.missing(
                    key: ["resetPassword", "fromAddress"],
                    file: keychainConfigFile,
                    desiredType: String.self
                )
        }

        let apiAccessConfig = keychainConfig["apiAccess"]
        let refreshTokenConfig = keychainConfig["refreshToken"]
        let resetPasswordConfig = keychainConfig["resetPassword"]

        self.init(
            baseURL: baseURL,
            emailViewPath: resetPasswordConfig?["pathToEmail"]?.string,
            fromEmailAddress: EmailAddress(
                name: fromName,
                address: fromAddress
            ),
            apiAccess: apiAccessConfig.flatMap(SignerParameters.init),
            refreshToken: refreshTokenConfig.flatMap(SignerParameters.init),
            resetPassword: resetPasswordConfig.flatMap(SignerParameters.init)
        )
    }
}
