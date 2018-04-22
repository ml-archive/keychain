import Vapor

public protocol PublicRepresentable {
    associatedtype Public: Content
    func convertToPublic() -> Public
}
