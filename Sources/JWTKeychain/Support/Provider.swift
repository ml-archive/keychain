import Core
import LeafProvider
import Vapor

public final class Provider: Vapor.Provider {
    public static let repositoryName = "jwt-keychain-provider"

    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_ config: Config) throws {
        config.preparations += [User.self]
    }

    public func boot(_ drop: Droplet) throws {
        registerTags(drop)
        try setUpFrontendRoutes(drop)
    }

    public func beforeRun(_ drop: Droplet) throws {}
}

// MARK: Helper
extension Provider {
    fileprivate func registerTags(_ drop: Droplet) {
        guard let stem = drop.stem else { return }

        stem.register(ErrorListTag())
        stem.register(ValueForFieldTag())
    }
    
    fileprivate func setUpFrontendRoutes(_ drop: Droplet) throws {
        let frontendController = try FrontendResetPasswordController(
            signer: drop.assertSigner(),
            viewRenderer: drop.view
        )
        let frontendRoutes = FrontendResetPasswordRoutes(
            resetPasswordController: frontendController
        )
        try drop.collection(frontendRoutes)
    }
}
