# Keychain ⛓
[![Swift Version](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4-30B6FC.svg)](http://vapor.codes)
[![Vapor Version](https://img.shields.io/badge/Vapor-3-30B6FC.svg)](http://vapor.codes)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![codebeat badge](https://codebeat.co/badges/04ee1891-95e9-483e-99c1-44a9191d1d8a)](https://codebeat.co/projects/github-com-nodes-vapor-jwt-keychain-master)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/jwt-keychain)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/jwt-keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/jwt-keychain/master/LICENSE)

Add a complete and customizable user authentication system for your API project.


## 📦 Installation

Update your `Package.swift` file.

```swift
.package(url: "https://github.com/nodes-vapor/keychain.git", from: "1.0.1")
```
```swift
targets: [
    .target(
        name: "App",
        dependencies: [
            ...
            .product(name: "Keychain", package: "keychain"),
        ]
    ),
    ...
]
```
## Usage
### Setup 
```swift
app.keychain.configure(
    signer: JWTSigner(
        algorithm: TestJWTAlgorithm(name: UserAccessKeychainConfig.jwkIdentifier.string)
    ),
    config: UserAccessKeychainConfig()
)
app.keychain.configure(
    signer: JWTSigner(
        algorithm: TestJWTAlgorithm(name: UserRefreshKeychainConfig.jwkIdentifier.string)
    ),
    config: UserRefreshKeychainConfig()
)
app.keychain.configure(
    signer: JWTSigner(
        algorithm: TestJWTAlgorithm(name: UserResetKeychainConfig.jwkIdentifier.string)
    ),
    config: UserResetKeychainConfig()
)
```

#### JWTPayload
```swift
import JWT
import Keychain
import Vapor

struct UserJWTPayload: KeychainPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    init(expirationDate: Date, user: User) {
        self.exp = .init(value: expirationDate)
        self.sub = .init(value: user.id)
    }

    func findUser(request: Request) -> EventLoopFuture<User> {
        request.eventLoop.future(request.testUser).unwrap(or: TestError.userNotFound)
    }

    func verify(using signer: JWTSigner) throws {
        // don't verify anything since we're not testing the JWT package itself
    }
}
```
#### KeychainConfigs
There are three types of tokens used by Keychain: refresh tokens, API access tokens, and password reset tokens.

Both refresh and access tokens should be included in the `Authorization` header for each request they are needed for, as follows: `Authorization: Bearer TOKEN` (where `TOKEN` is replaced with the actual token string).
```swift
import JWT
import Keychain

struct UserAccessKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "access"

    let expirationTimeInterval: TimeInterval = 300
}

struct UserRefreshKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "refresh"

    let expirationTimeInterval: TimeInterval = 600
}

struct UserResetKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "reset"

    let expirationTimeInterval: TimeInterval = 400
}
```

#### UserController
```swift
import Keychain

struct UserController {
    let currentDate: () -> Date

    func login(request: Request) -> EventLoopFuture<AuthenticationResponse<UserResponse>> {
        UserLoginRequest
            .logIn(
                on: request,
                errorOnWrongPassword: TestError.incorrectCredentials,
                currentDate: currentDate()
            ).map { $0.map(UserResponse.init) }
    }

    func register(request: Request) -> EventLoopFuture<AuthenticationResponse<UserResponse>> {
        UserRegisterRequest
            .register(
                on: request,
                currentDate: currentDate()
            ).map {
                request.testUser = $0.user
                return $0.map(UserResponse.init)
            }
    }

    func forgotPassword(request: Request) -> EventLoopFuture<HTTPStatus> {
        UserForgotPasswordRequest
            .sendToken(on: request, currentDate: currentDate())
            .transform(to: .accepted)
    }

    func resetPassword(request: Request) -> EventLoopFuture<HTTPStatus> {
        UserResetPasswordRequest
            .updatePassword(on: request)
            .map { request.testUser = $0}
            .transform(to: .ok)
    }

    func refreshToken(request: Request) throws -> Response {
        let token = try UserRefreshKeychainConfig.makeToken(on: request, currentDate: currentDate())

        // here we encode the token string as JSON but you might include your token in a struct
        // conforming to `Content`
        let response = Response()
        try response.content.encode(token, as: .json)
        return response
    }

    func me(request: Request) throws -> UserResponse {
        try .init(user: request.auth.require(User.self))
    }
}
```

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
