import Vapor

struct TestHasher: PasswordHasher {
    init(_: Application) {}

    func verify<Password: DataProtocol, Digest: DataProtocol>(
        _ password: Password,
        created digest: Digest
    ) throws -> Bool {
         ("$".compactMap { $0.asciiValue } + password.map { $0 }) == digest.map { $0 }
    }

    func hash<Password>(_ password: Password) throws -> [UInt8] where Password : DataProtocol {
        "$".compactMap { $0.asciiValue } + password.map { $0 }
    }
}
