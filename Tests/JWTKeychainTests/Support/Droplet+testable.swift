import JWTKeychain
import JWTProvider
import LeafProvider
import Sessions
import Vapor

import FluentProvider

extension Droplet {
    static func testable() throws -> Droplet {
        var config = Config([:])
        
        try config.set("fluent.driver", "memory")
        try config.set("app.url", "https://example.com")
        try config.set(
            "jwt-keychain.resetPassword",
            ["fromName": "Sender",
             "fromAddress": "sender@email.com"]
        )
        try config.set(
            "jwt.signers",
            [
                "access": ["type": "unsigned"],
                "refresh": ["type": "unsigned"],
                "reset": ["type": "unsigned"]
            ]
        )
        try config.addProvider(FluentProvider.Provider.self)
        try config.addProvider(LeafProvider.Provider.self)
        try config.addProvider(JWTKeychain.Provider.self)
        
        return try Droplet(
            config: config,
            middleware: [SessionsMiddleware(MemorySessions())],
            view: CapturingViewRenderer()
        )
    }
}
