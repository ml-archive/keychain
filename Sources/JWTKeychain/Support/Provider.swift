import Core
import JWT
import JWTProvider
import Leaf
import LeafProvider
import SMTP
import Vapor

/// Provider that sets up:
/// - User API routes
/// - Frontend password reset routes
/// - Password Reset Mailer
public final class Provider: Vapor.Provider {
    public static let repositoryName = "jwt-keychain-provider"
    
    fileprivate let baseURL: String
    fileprivate let emailViewPath: String
    
    fileprivate let fromEmailAddress: EmailAddress

    fileprivate let apiAccess: SignerParameters
    fileprivate let refreshToken: SignerParameters?
    fileprivate let resetPassword: SignerParameters

    /**
     - parameter baseURL: base URL of the app; used for password reset link.
     - parameter emailViewPath: path to view used to render password reset email html.
     - parameter fromEmailAddress: sender
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

    public convenience init(config: Config) throws {
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
        
        guard let fromName = keychainConfig["resetPassword", "fromName"]?.string else {
            throw ConfigError.missing(
                key: ["resetPassword", "fromName"],
                file: keychainConfigFile,
                desiredType: String.self
            )
        }
        
        guard let fromAddress = keychainConfig["resetPassword", "fromAddress"]?.string else {
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
            fromEmailAddress: EmailAddress(name: fromName, address: fromAddress),
            apiAccess: apiAccessConfig.flatMap(SignerParameters.init),
            refreshToken: refreshTokenConfig.flatMap(SignerParameters.init),
            resetPassword: resetPasswordConfig.flatMap(SignerParameters.init)
        )
    }

    public func boot(_ config: Config) throws {
        config.preparations += [User.self]
        
        try config.addProvider(JWTProvider.Provider.self)
    }

    public func boot(_ drop: Droplet) throws {
        try registerRoutes(drop)
    }

    public func beforeRun(_ drop: Droplet) throws {
        if let stem = drop.stem {
            registerTags(stem)
        }
    }
}

// MARK: Helper
extension Provider {
    fileprivate func registerRoutes(_ drop: Droplet) throws {
        let signerMap = try drop.assertSigners()
        let viewRenderer = drop.view
        
        let frontendRoutes = try createFrontendRoutes(
            signerMap: signerMap,
            viewRenderer: viewRenderer
        )

        let mailer = try drop.config.resolveMail()
        let passwordResetMailer = PasswordResetMailer(
            baseURL: baseURL,
            emailViewPath: emailViewPath,
            expirationPeriod: resetPassword.expireIn,
            fromEmailAddress: fromEmailAddress,
            mailer: mailer,
            viewRenderer: viewRenderer)
        let userRoutes = try createUserRoutes(
            passwordResetMailer: passwordResetMailer,
            signerMap: signerMap
        )
        
        try drop.collection(frontendRoutes)
        try drop.collection(userRoutes)
    }
    
    fileprivate func registerTags(_ stem: Stem) {
        stem.register(ErrorListTag())
        stem.register(ValueForFieldTag())
    }
    
    fileprivate func createFrontendRoutes(
        signerMap: SignerMap,
        viewRenderer: ViewRenderer
    ) throws -> FrontendResetPasswordRoutes {
        guard let signer = signerMap[resetPassword.kid] else {
            throw JWTKeychainError.missingSigner(kid: resetPassword.kid)
        }
        
        let controller = FrontendResetPasswordController<User>(
            signer: signer,
            viewRenderer: viewRenderer
        )
        
        return FrontendResetPasswordRoutes(
            resetPasswordController: controller
        )
    }
    
    fileprivate func createUserRoutes(
        passwordResetMailer: PasswordResetMailerType,
        signerMap: SignerMap
    ) throws -> APIUserRoutes {
        let apiAccessTokenGenerator = try ExpireableSigner(
            signerParameters: apiAccess,
            signerMap: signerMap
        )

        let refreshTokenGenerator: ExpireableSigner?
        if let refreshToken = refreshToken {
            refreshTokenGenerator = try ExpireableSigner(
                signerParameters: refreshToken,
                signerMap: signerMap
            )
        } else {
            refreshTokenGenerator = nil
        }
        
        let resetPasswordTokenGenerator = try ExpireableSigner(
            signerParameters: resetPassword,
            signerMap: signerMap
        )
        
        let userAuthenticator = UserAuthenticator()

        let controller = UserController(
            passwordResetMailer: passwordResetMailer,
            apiAccessTokenGenerator: apiAccessTokenGenerator,
            refreshTokenGenerator: refreshTokenGenerator,
            resetPasswordTokenGenerator: resetPasswordTokenGenerator,
            userAuthenticator: userAuthenticator
        )
        
        let apiAccessMiddleware = PayloadAuthenticationMiddleware<User>(
            apiAccessTokenGenerator,
            [ExpirationTimeClaim()]
        )

        let refreshMiddleware: Middleware?

        if let refreshTokenGenerator = refreshTokenGenerator {
            refreshMiddleware = PayloadAuthenticationMiddleware<User>(
                refreshTokenGenerator,
                [ExpirationTimeClaim()]
            )
        } else {
            refreshMiddleware = nil
        }
        
        return APIUserRoutes(
            apiAccessMiddleware: apiAccessMiddleware,
            refreshMiddleware: refreshMiddleware,
            userController: controller
        )
    }
}

enum JWTKeychainError: Error {
    case missingSigner(kid: String)
}
