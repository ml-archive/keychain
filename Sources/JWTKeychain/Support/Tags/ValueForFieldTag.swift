import Leaf

public final class ValueForFieldTag: BasicTag {
    public let name = "valueForField"

    // Argument 1: fields
    // Argument 2: field name
    //
    // Output: node with the value for the key of the field with the given name
    public func run(
        arguments: ArgumentList
    ) throws -> Node? {
        guard
            arguments.count == 2,
            let fields = arguments[0]?.object,
            let fieldName = arguments[1]?.string
        else {
            return nil
        }
        return fields[fieldName]?["value"]
    }
}
