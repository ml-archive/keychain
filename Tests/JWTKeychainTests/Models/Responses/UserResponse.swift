import Vapor

struct UserResponse: Content, Equatable {
    let name: String
}

extension UserResponse {
    init(user: User) {
        self.name = user.name
    }
}
