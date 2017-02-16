import Node
import JWT

public struct UserClaim: Claim {
    public static var name = "user"

    public let value: Node

    public var node: Node

    public init(_ value: Node) {
        self.value = value
        self.node = value
    }

    public func verify(_ node: Node) -> Bool {

        if let _ = node.object?["id"]?.int {
            return true
        }

        return false

    }

}
