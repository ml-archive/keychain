import Validation

public class EqualityValidator<T: Equatable>: Validator {
    private let errorMessage: String

    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }

    public func validate(_ input: Pair<T>) throws {
        guard input.left == input.right else {
            throw error(errorMessage)
        }
    }
}

public struct PasswordPair: AutoValidatable {
    public static var validator = EqualityValidator<String>(errorMessage: "Passwords do not match")
}

// workaround for not being able conform tuples to protocols
public struct Pair<T>: Validatable {
    let left: T
    let right: T

    init(left: T, right: T) {
        self.left = left
        self.right = right
    }
}
