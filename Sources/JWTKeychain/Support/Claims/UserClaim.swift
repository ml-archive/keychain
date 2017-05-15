import Node
import JWT

public protocol UserClaimRepresentable {
    func makeUserClaim() throws -> UserClaim
}

public struct UserClaim: Claim {
    public static var name = "user"

    public let value: Node

    public var node: Node {
        return value
    }

    public init(_ value: Node) {
        self.value = value
    }

    public func verify(_ node: Node) -> Bool {
        return node.object?["id"]?.int != nil
    }
}
