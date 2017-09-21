import Authentication
import Core
import Flash
import FluentProvider
import Forms
import JWT
import JWTProvider
import Leaf
import LeafProvider
import SMTP
import Vapor

public typealias JWTKeychainUser =
    EmailAddressRepresentable &
    Entity &
    JSONRepresentable &
    JWTKeychainAuthenticatable &
    NodeRepresentable &
    PasswordAuthenticatable &
    PasswordResettable &
    PasswordUpdateable &
    PayloadAuthenticatable &
    Preparation

private var _bCryptHasher = BCryptHasher()

extension PasswordAuthenticatable {
    public static var bCryptHasher: BCryptHasher {
        return _bCryptHasher
    }
}

/// Provider that sets up:
/// - User API routes
/// - Frontend password reset routes
/// - Password Reset Mailer
public final class Provider<U: JWTKeychainUser> {

    fileprivate let settings: Settings

    fileprivate let apiDelegate: APIUserControllerDelegateType
    fileprivate let apiMiddleware: [Middleware]
    fileprivate let frontendDelegate: FrontendUserControllerDelegateType
    fileprivate let frontendMiddleware: [Middleware]

    public init(
        apiDelegate: APIUserControllerDelegateType? = nil,
        apiMiddleware: [Middleware] = [],
        frontendDelegate: FrontendUserControllerDelegateType? = nil,
        frontendMiddleware: [Middleware] = [FlashMiddleware(), FieldsetMiddleware()],
        settings: Settings
    ) {
        self.apiDelegate = apiDelegate ?? APIUserControllerDelegate<U>()
        self.apiMiddleware = apiMiddleware
        self.frontendDelegate = frontendDelegate ??
            FrontendUserControllerDelegate<U>(
                settings: settings
        )
        self.frontendMiddleware = frontendMiddleware
        self.settings = settings

        if let bCryptCost = settings.bCryptCost {
            _bCryptHasher = BCryptHasher(cost: bCryptCost)
        }
    }
}

// MARK: Vapor.Provider

extension Provider: Vapor.Provider {
    public static var repositoryName: String {
        return "jwt-keychain-provider"
    }

    public func boot(_ config: Config) throws {
        config.preparations += [U.self]

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

// MARK: Configinitializable

extension Provider: ConfigInitializable {
    public convenience init(config: Config) throws {
        try self.init(settings: Settings(config: config))
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
            mailer: mailer,
            settings: settings,
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
        let kid = settings.resetPassword.kid
        guard let signer = signerMap[kid] else {
            throw JWTKeychainError.missingSigner(kid: kid)
        }
        
        let controller = FrontendUserController(
            signer: signer,
            viewRenderer: viewRenderer,
            delegate: frontendDelegate
        )
        
        return FrontendResetPasswordRoutes(
            controller: controller,
            middleware: frontendMiddleware,
            pathPrefix: settings.frontendPathPrefix
        )
    }
    
    fileprivate func createUserRoutes(
        passwordResetMailer: PasswordResetMailerType,
        signerMap: SignerMap
    ) throws -> APIUserRoutes {
        let tokenGenerators = try TokenGenerators(
            settings: settings,
            signerMap: signerMap
        )
        
        let controller = APIUserController(
            delegate: apiDelegate,
            passwordResetMailer: passwordResetMailer,
            tokenGenerators: tokenGenerators
        )
        
        let apiAccessMiddleware = PayloadAuthenticationMiddleware<U>(
            tokenGenerators.apiAccess,
            [ExpirationTimeClaim()]
        )

        // Expose API Access Middleware for public usage
        Middlewares.secured.append(apiAccessMiddleware)

        let refreshMiddleware: Middleware?

        if let refresh = tokenGenerators.refresh {
            refreshMiddleware = PayloadAuthenticationMiddleware<U>(
                refresh,
                [ExpirationTimeClaim()]
            )
        } else {
            refreshMiddleware = nil
        }
        
        return APIUserRoutes(
            apiAccessMiddleware: apiAccessMiddleware,
            refreshMiddleware: refreshMiddleware,
            commonMiddleware: apiMiddleware,
            controller: controller,
            pathPrefix: settings.apiPathPrefix
        )
    }
}
