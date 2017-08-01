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
        let stem = try drop.assertStem()

        stem.register(ErrorListTag())
        stem.register(ValueForFieldTag())
    }

    public func beforeRun(_ drop: Droplet) throws {}
}
