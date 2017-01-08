import XCTest
@testable import Vapor
@testable import JWTKeychain
import HTTP

class JWTAuthMiddlewareTests: XCTestCase {
    
    private var middleware: JWTAuthMiddleware
    
    static var allTests : [(String, (JWTAuthMiddlewareTests) -> () throws -> Void)] {
        return [
            ("testThatAuthorizationHeaderIsRequired", testThatAuthorizationHeaderIsRequired)
        ]
    }
    
    override func setUp() {
        let drop = Droplet()
        
        do{
            self.middleware = try JWTAuthMiddleware(drop: drop)
        } catch {
            XCTFail("Unable to initialize JWT middleware")
        }
        
    }
    
    override func tearDown() {
        
    }
    
    
    // MARK: Authorization header required
    func testThatAuthorizationHeaderIsRequired() {
        
        let next = ResponderMock()

        let req = try? Request(method: .get, uri: "some-random-uri")
        
        do {
            _ = try middleware.respond(to: req!, chainingTo: next)
            XCTFail("No auth header should Abort.")
        } catch {}
        
    }
    
}
