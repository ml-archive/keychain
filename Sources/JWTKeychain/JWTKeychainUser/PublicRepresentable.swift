import Vapor

public protocol PublicRepresentable {
    associatedtype Public: Content
    func convertToPublic(on db: DatabaseConnectable) throws -> Future<Public>
}
