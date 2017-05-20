import Authentication
import JWT

public protocol TokenCreating {
    func createToken(using: Signer) throws -> Token
}
