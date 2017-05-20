import Fluent
import Validation
import Vapor

public final class ValidName: Validator {
    public init() {}

    public func validate(_ input: String) throws {
        // TODO: decide on good standards for name validation. 
        guard input.characters.count > 0, input.characters.count < 256 else {
            throw error("Name should be between 1 and 255 characters in length")
        }
    }
}

// TODO: replace with Sugar's version when it's available
public final class StrongPassword: Validator {
    public init() {}

    public func validate(_ input: String) throws {}
}

// TODO: add extra options for filtering
public final class UniqueValidator<T: Entity>: Validator {
    let fieldName: String

    init(fieldName: String) {
        self.fieldName = fieldName
    }

    public func validate(_ input: String) throws {
        let entity = try T.makeQuery().filter(fieldName, input).first()
        if entity != nil {
            throw error("An instance of \(T.name) with that \(fieldName) already exists")
        }
    }
}
