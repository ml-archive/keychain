import Fluent
import Validation
import Vapor

public final class UniqueEntity<T: Entity>: Validator {
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
