import Vapor
//TODO: replace this with Submissions
public protocol RequestInitializable {
    init(request: Request) throws
}

public extension RequestInitializable where Self: Decodable {
    init(request: Request) throws {
        self = try request.content.decode(Self.self)
    }
}
