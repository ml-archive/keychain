import Leaf

/**
 Example usage:

 #errorList(resetPasswordFields, "email") {
 <ul class="errorlist">
 #loop(errors, "error") {
 <li>#(error)</li>
 }
 </ul>
 }

 If there are no errors there will be no output
 */
public final class ErrorListTag: BasicTag {
    public let name = "errorList"

    // Argument 1: fields
    // Argument 2: field name
    //
    // Output: a node with an array for the key "errors" or nil
    public func run(
        arguments: ArgumentList
    ) throws -> Node? {
        guard
            arguments.count == 2,
            let fields = arguments[0]?.object,
            let fieldName = arguments[1]?.string,
            let errors = fields[fieldName]?["errors"]?.array,
            errors.count > 0
            else {
                return nil
        }

        return ["errors": .array(errors)]
    }
}
