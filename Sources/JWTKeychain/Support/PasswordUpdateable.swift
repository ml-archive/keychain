public protocol PasswordUpdateable {
    func updatePassword(to: String) throws

    var passwordVersion: Int { get set }
}
