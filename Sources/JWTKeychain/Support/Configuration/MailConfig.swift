import Vapor

public struct MailConfig: ConfigInitializable {
    internal let user: String
    internal let password: String
    internal let fromEmail: String
    internal let name: String
    internal let smtpHost: String
    internal let smtpPort: Int
    internal let smtpScheme: String

    public init(config: Config) throws {
        user = try config.get("user")
        password = try config.get("password")
        fromEmail = try config.get("fromEmail")
        name = try config.get("name")
        smtpHost = try config.get("smtpHost")
        smtpPort = try config.get("smtpPort")
        smtpScheme = try config.get("smtpScheme")
    }
}
