import Vapor

public struct AppConfig {
    internal let url: String
    internal let name: String

    public init(_ config: Config) throws {
        url = try config.get("url")
        name = try config.get("name")
    }
}
