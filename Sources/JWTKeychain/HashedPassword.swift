import Crypto

public struct HashedPassword: Codable, Equatable {
    public let value: String
    fileprivate init(_ input: LosslessStringConvertible) {
        value = input.description
    }
}

extension HashedPassword: ReflectionDecodable {
    public static func reflectDecoded() throws -> (HashedPassword, HashedPassword) {
        return (.init(0), .init(1))
    }
}
import MySQL
extension HashedPassword: MySQLDataConvertible {
    public func convertToMySQLData() throws -> MySQLData {
        return MySQLData(string: value)
    }

    public static func convertFromMySQLData(_ mysqlData: MySQLData) throws -> HashedPassword {
        return try self.init(mysqlData.decode(String.self))
    }
}

extension JWTCustomPayloadKeychainUser {
    public static func hashPassword(_ data: LosslessDataConvertible) throws -> HashedPassword {
        return try HashedPassword(BCrypt.hash(data, cost: bCryptCost).base64EncodedString())
    }
}
