import Authentication
import Fluent

public protocol TokenGenerator {
    func generateToken<E>(
        for: E
    ) throws -> Token where E: PasswordUpdateable, E: Entity
}
