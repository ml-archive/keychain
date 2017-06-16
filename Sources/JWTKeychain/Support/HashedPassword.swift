import Vapor

extension HashProtocol {
    
    /// Create a HashedPassword from a validated password
    /// - Parameter password: a validated password
    /// - Throws: when password hashing fails
    /// - Returns: an instance of a HashedPassword
    func hash(_ password: Valid<Password>) throws -> HashedPassword {
        return try HashedPassword(make(password.value.makeBytes()).makeString())
    }
}

/// Wraps a String value. Can only exist as a valid, hashed password.
public struct HashedPassword {
    public let value: String

    // keep this fileprivate to make prevent creating invalid instances
    fileprivate init(_ value: String) {
        self.value = value
    }
}
