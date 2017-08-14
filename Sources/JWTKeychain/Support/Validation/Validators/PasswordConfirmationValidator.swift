import Node
import Validation

public class PasswordConfirmationValidator: Validator {
    public init() {}

    public func validate(_ input: PasswordConfirmation) throws {
        guard input.password == input.passwordConfirmation else {
            throw error("Passwords do not match.")
        }
    }
}

public struct PasswordConfirmation: Validatable {
    let password: String
    let passwordConfirmation: String

    init?(password: String?, passwordConfirmation: String?) {
        guard
            let password = password,
            let passwordConfirmation = passwordConfirmation else {
                return nil
        }
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}

extension PasswordConfirmation: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return .string(passwordConfirmation)
    }
}
