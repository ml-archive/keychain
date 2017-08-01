import Node
import Validation

public class PasswordConfirmationValidator: Validator {
    public init() {}

    public func validate(_ input: PasswordConfirmation) throws {
        guard let passwordConfirmation = input.passwordConfirmation else {
            throw error("Password confirmation cannot be empty.")
        }
        guard input.password == passwordConfirmation else {
            throw error("Passwords do not match.")
        }
    }
}

public struct PasswordConfirmation: Validatable {
    let password: String?
    let passwordConfirmation: String?

    init(password: String?, passwordConfirmation: String?) {
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}

extension PasswordConfirmation: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return passwordConfirmation.map { Node.string($0) } ?? .null
    }
}
