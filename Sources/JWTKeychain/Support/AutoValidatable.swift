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
    public static var validator: ValidName {
        return ValidName()
    }
}

public enum Email: AutoValidatable {
    public static var validator: ValidatorList<String> {
        return EmailValidator() && UniqueValidator<User>(fieldName: User.Keys.email)
    }
}

