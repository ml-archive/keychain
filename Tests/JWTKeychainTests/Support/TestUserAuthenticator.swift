@testable import JWTKeychain
import Vapor

class TestUserAuthenticator: UserAuthenticating {
    typealias U = TestUser

    private let user: TestUser
    var action: String?

    init(user: TestUser) {
        self.user = user
    }

    private func handleAction(function: String = #function) -> U {
        action = function
        return user
    }

    func find(request: Request) throws -> U {
        return handleAction()
    }

    func logIn(request: Request) throws -> U {
        return handleAction()
    }

    func logOut(request: Request) throws -> U {
        return handleAction()
    }

    func make(request: Request) throws -> U {
        return handleAction()
    }

    func update(request: Request) throws -> U {
        return handleAction()
    }
}
