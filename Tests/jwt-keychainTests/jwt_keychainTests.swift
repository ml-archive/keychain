import XCTest
@testable import jwt_keychain

class jwt_keychainTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(jwt_keychain().text, "Hello, World!")
    }


    static var allTests : [(String, (jwt_keychainTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
