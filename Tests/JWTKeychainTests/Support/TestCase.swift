import JSON
import JWT
import Testing
import Vapor
import XCTest

//sourcery:excludeFromLinuxMain
class TestCase: XCTestCase {
    let drop = try! Droplet.testable()

    override class func setUp() {
        super.setUp()
        Testing.onFail = XCTFail
    }
}

// MARK: Helper

extension TestCase {
    func createToken(
        password: String = "hashedpassword",
        kid: String = "reset"
    ) throws -> String {
        var payload = JSON()
        payload["nodes:pwd"] = .string(password)
        payload["sub"] = .string("1")
        payload["exp"] = .number(.int(Int(1.hour.fromNow!.timeIntervalSince1970)))

        let jwt = try JWT(
            payload: payload,
            signer: drop.assertSigner(kid: kid)
        )
        return try jwt.createToken()
    }
}
