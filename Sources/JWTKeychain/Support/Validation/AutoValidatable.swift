import Sugar
import Validation

public protocol AutoValidatable: Validatable {
    associatedtype V: Validator

    static var validator: V { get }
}

public final class Valid<T: AutoValidatable> {
    init(_ value: T.V.Input) throws {
        try value.validated(by: T.validator)
        self.value = value
    }

    let value: T.V.Input
}

public enum Password: AutoValidatable {
    public static var validator: StrongPassword {
        return StrongPassword()
    }
}

public enum Name: AutoValidatable {
    // TODO: decide on good standards for name validation.
    public static var validator = Count<String>.containedIn(low: 2, high: 256)
}

public enum Email: AutoValidatable {
    public static var validator = EmailValidator()
}

public enum UniqueEmail: AutoValidatable {
    public static var validator: ValidatorList<String> =
        EmailValidator() && UniqueEntity<User>(fieldName: User.Keys.email)
}
