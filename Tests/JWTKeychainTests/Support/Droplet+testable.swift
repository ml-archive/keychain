import JWTKeychain
import JWTProvider
import Sessions
import Vapor

extension Droplet {
    static func testable() throws -> Droplet {
        let config = Config(.null)
        try config.addProvider(JWTProvider.Provider(signer: TestSigner()))
        try config.addProvider(JWTKeychain.Provider.self)
        
        return try Droplet(
            config: config,
            middleware: [SessionsMiddleware(MemorySessions())],
            view: CapturingViewRenderer()
        )
    }
}
