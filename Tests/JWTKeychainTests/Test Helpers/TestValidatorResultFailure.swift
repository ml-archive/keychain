import Vapor

extension ValidatorResults {
    struct TestFailure: ValidatorResult {
        var isFailure: Bool { true }
        var successDescription: String? { nil }
        var failureDescription: String? { "has failed" }
    }
}
