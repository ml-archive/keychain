import Vapor

public struct KeychainConfig {
    internal let resetPasswordEmailViewPath: String
    internal let resetPasswordTokenExpirationTime: Double

    public init(_ config: Config) throws {
        resetPasswordEmailViewPath = try config.get("resetPasswordEmailViewPath")
        resetPasswordTokenExpirationTime = try config.get("resetPasswordTokenExpirationTime")
    }
}
