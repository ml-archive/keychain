import Validation
import Vapor

public class FormField<T: AutoValidatable> {
    typealias Input = T.V.Input

    fileprivate let errors: [Error]
    fileprivate let name: String
    fileprivate let value: Input

    init(_ value: Input, name: String) {
        self.name = name
        self.value = value

        do {
            _ = try Valid<T>(value)
            errors = []
        } catch let errorList as ErrorList {
            errors = errorList.errors
        } catch {
            errors = [error]
        }
    }
}

extension FormField: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return try Node(
            node: [
                name: [
                    "value": value,
                    "errors": errors.map { $0.localizedDescription }
                ]
            ]
        )
    }
}
