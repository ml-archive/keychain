import JSON
import JWT
import Testing
import Vapor
import XCTest

//sourcery:excludeFromLinuxMain
class TestCase: XCTestCase {
    let drop = try! Droplet.testable()

    override func setUp() {
        Testing.onFail = XCTFail
    }
}

// MARK: Helper

extension TestCase {
    func createToken(password: String = "hashedpassword") throws -> String {
        var payload = JSON()
        payload["nodes:pwd"] = .string(password)
        payload["sub"] = .string("1")

        let jwt = try JWT(
            headers: JSON(),
            payload: payload,
            signer: drop.assertSigner()
        )
        return try jwt.createToken()
    }
}
