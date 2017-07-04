import Vapor

public struct KeychainConfig: ConfigInitializable {
    internal let resetPasswordEmailViewPath: String
    internal let resetPasswordTokenExpirationTime: Double

    public init(config: Config) throws {
        resetPasswordEmailViewPath = try config.get("resetPasswordEmailViewPath")
        resetPasswordTokenExpirationTime = try config.get("resetPasswordTokenExpirationTime")
    }
}
