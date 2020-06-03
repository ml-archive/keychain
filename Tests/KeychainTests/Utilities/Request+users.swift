import Vapor

extension Request {
    var testUser: User? {
        get {
            application.users.testUser
        }
        set {
            application.users.testUser = newValue
        }
    }
}
