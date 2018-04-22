/// Types conforming to this protocol can be used for login or register requests
public protocol PasswordPayload: Decodable {
    var password: String { get }
}
