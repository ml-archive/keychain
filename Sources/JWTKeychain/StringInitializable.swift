import Foundation

public protocol StringInitializable {
    init?(string: String)
}

extension Int: StringInitializable {
    public init?(string: String) {
        self.init(string)
    }
}

extension UUID: StringInitializable {
    public init?(string: String) {
        self.init(string)
    }
}

extension String: StringInitializable {
    public init?(string: String) {
        self = string
    }
}
