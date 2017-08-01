import Testing
import XCTest

class TestCase: XCTestCase {
    override func setUp() {
        Testing.onFail = XCTFail
    }
}
