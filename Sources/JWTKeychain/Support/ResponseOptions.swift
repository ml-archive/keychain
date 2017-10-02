public struct ResponseOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: ResponseOptions.RawValue) {
        self.rawValue = rawValue
    }

    public static let access = ResponseOptions(rawValue: 1 << 0)
    public static let refresh = ResponseOptions(rawValue: 1 << 1)
    public static let user = ResponseOptions(rawValue: 1 << 2)

    public static let all: ResponseOptions = [.access, .refresh, .user]
}
