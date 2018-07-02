import Vapor

public protocol PublicRepresentable {
    associatedtype Public: Content
    func convertToPublic(on req: Request) throws -> Future<Public>
}
