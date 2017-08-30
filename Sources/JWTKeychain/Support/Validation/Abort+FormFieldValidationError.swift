import Forms
import Vapor

extension Abort: FormFieldValidationError {
    public var errorReasons: [String] {
        return [reason]
    }
}
