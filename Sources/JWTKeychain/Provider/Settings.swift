import SMTP
import Vapor

public struct Settings {
    public let baseURL: String

    public let pathToEmailView: String
    public let pathToFormView: String

    public let fromEmailAddress: EmailAddress

    public let apiPathPrefix: String
    public let frontendPathPrefix: String

    public let apiAccess: SignerParameters
    public let refreshToken: SignerParameters?
    public let resetPassword: SignerParameters

    public let bCryptCost: UInt?

    /// Initializes the Settings object.
    ///
    /// - Parameters:
    ///   - baseURL: base URL of the app; used for password reset link
    ///   - pathToEmailView: path to view for rendering password reset email
    ///   - pathToFormView: path to view used to render password reset form
    ///   - fromEmailAddress: sender
    ///   - apiPathPrefix: path prefix for api routes
    ///   - frontendPathPrefix: path prefix for frontend routes
    ///   - apiAccess: signer parameters for API access routes.
    ///     Defaults to "kid": "access" and a 1 hour expiration period.
    ///   - refreshToken: signer parameters for refresh token route.
    ///     Defaults to "kid": "refresh" and a 1 year expiration period.
    ///   - resetPassword: signer parameters for reset password link.
    ///     Defaults to "kid": "reset" and a 1 hour expiration period.
    public init(
        baseURL: String,
        pathToEmailView: String?,
        pathToFormView: String?,
        fromEmailAddress: EmailAddress,
        apiPathPrefix: String?,
        frontendPathPrefix: String?,
        apiAccess: SignerParameters?,
        refreshToken: SignerParameters?,
        resetPassword: SignerParameters?,
        bCryptCost: UInt?
    ) {
        self.baseURL = baseURL
        self.pathToEmailView = pathToEmailView ?? "Emails/resetPassword"
        self.pathToFormView = pathToFormView ?? "Views/resetPassword"
        self.fromEmailAddress = fromEmailAddress
        self.apiPathPrefix = apiPathPrefix ?? ""
        self.frontendPathPrefix = frontendPathPrefix ?? ""
        self.apiAccess = apiAccess ?? SignerParameters(kid: "access")
        self.refreshToken = refreshToken
        self.resetPassword = resetPassword ?? SignerParameters(kid: "reset")
        self.bCryptCost = bCryptCost
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

        guard let fromName = keychainConfig["fromName"]?.string else {
            throw ConfigError.missing(
                key: ["fromName"],
                file: keychainConfigFile,
                desiredType: String.self
            )
        }

        guard let fromAddress = keychainConfig["fromAddress"]?.string else {
            throw ConfigError.missing(
                key: ["fromAddress"],
                file: keychainConfigFile,
                desiredType: String.self
            )
        }

        let apiAccessConfig = keychainConfig["apiAccess"]
        let refreshTokenConfig = keychainConfig["refreshToken"]
        let resetPasswordConfig = keychainConfig["resetPassword"]

        self.init(
            baseURL: baseURL,
            pathToEmailView: keychainConfig["pathToEmailView"]?.string,
            pathToFormView: keychainConfig["pathToFormView"]?.string,
            fromEmailAddress: EmailAddress(
                name: fromName,
                address: fromAddress
            ),
            apiPathPrefix: keychainConfig["apiPathPrefix"]?.string,
            frontendPathPrefix: keychainConfig["frontendPathPrefix"]?.string,
            apiAccess: apiAccessConfig.flatMap(SignerParameters.init),
            refreshToken: refreshTokenConfig.flatMap(SignerParameters.init),
            resetPassword: resetPasswordConfig.flatMap(SignerParameters.init),
            bCryptCost: keychainConfig["bCryptCost"]?.uint
        )
    }
}
