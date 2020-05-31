import Vapor

final class User: Authenticatable {
    let id = "userID"
    let name: String
    var hashedPassword: String

    init(name: String, hashedPassword: String) {
        self.name = name
        self.hashedPassword = hashedPassword
    }

    static let test = User(name: "Ida", hashedPassword: "$secret")
}
