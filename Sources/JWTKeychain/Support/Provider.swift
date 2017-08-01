import Core
import LeafProvider
import Vapor

public final class Provider: Vapor.Provider {
    public static let repositoryName = "jwt-keychain-provider"

    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_ config: Config) throws {}

    public func boot(_ drop: Droplet) throws {
        if let stem = drop.stem {
            stem.register(ErrorListTag())
            stem.register(ValueForFieldTag())
        }

        let frontendController = try FrontendResetPasswordController(
            signer: drop.assertSigner(),
            viewRenderer: drop.view
        )
        let frontendRoutes = FrontendResetPasswordRoutes(
            resetPasswordController: frontendController
        )
        try drop.collection(frontendRoutes)
    }

    public func beforeRun(_ drop: Droplet) throws {}
}
