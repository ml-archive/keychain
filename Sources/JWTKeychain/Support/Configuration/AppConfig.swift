import Vapor

public struct AppConfig: ConfigInitializable {
    internal let url: String
    internal let name: String

    public init(config: Config) throws {
        url = try config.get("url")
        name = try config.get("name")
    }
}
