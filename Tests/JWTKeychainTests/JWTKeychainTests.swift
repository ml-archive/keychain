import XCTest
@testable import JWTKeychain

class JWTKeychainTests: XCTestCase {
    
    static var allTests : [(String, (JWTKeychainTests) -> () throws -> Void)] {
        return [
            ("testThatAuthorizationHeaderIsRequired", testThatAuthorizationHeaderIsRequired)
        ]
    }
    
}
