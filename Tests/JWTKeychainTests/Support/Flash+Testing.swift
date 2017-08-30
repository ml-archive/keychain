import Flash
import HTTP
import Node
import XCTest

extension Response {
    private func extractFlashNode(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Node? {
        guard let node = storage["_flash"] as? Node else {
            XCTFail("No flash present", file: file, line: line)
            return nil
        }

        return node
    }

    @discardableResult
    func assertFlashType(
        is expectedType: Helper.FlashType,
        withMessage expectedMessage: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Response {
        guard let flashNode = extractFlashNode(file: file, line: line) else {
            return self
        }

        guard let message = flashNode[expectedType.rawValue]?.string else {
            XCTFail(
                "Flash is not of type: \"\(expectedType.rawValue)\"",
                file: file,
                line: line)
            return self
        }

        XCTAssertEqual(expectedMessage, message, file: file, line: line)
        
        return self
    }
}
