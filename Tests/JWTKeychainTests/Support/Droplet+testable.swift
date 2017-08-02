import JWTKeychain
import JWTProvider
import Sessions
import Vapor

import FluentProvider

extension Droplet {
    static func testable() throws -> Droplet {
        var config = Config([:])
        try config.set("fluent.driver", "memory")
        
        try config.addProvider(JWTProvider.Provider(signer: TestSigner()))
        try config.addProvider(JWTKeychain.Provider.self)
        try config.addProvider(FluentProvider.Provider.self)
        
        return try Droplet(
            config: config,
            middleware: [SessionsMiddleware(MemorySessions())],
            view: CapturingViewRenderer()
        )
    }
}
