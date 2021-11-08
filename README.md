# Keychain ⛓
[![Swift Version](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4-30B6FC.svg)](http://vapor.codes)
![tests](https://github.com/nodes-vapor/keychain/workflows/test/badge.svg)
[![codebeat badge](https://codebeat.co/badges/04ee1891-95e9-483e-99c1-44a9191d1d8a)](https://codebeat.co/projects/github-com-nodes-vapor-jwt-keychain-master)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/keychain)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/keychain/main/LICENSE)

Keychain adds a complete and customizable user authentication system to your API project.

## 📦 Installation

Update your `Package.swift` file.

```swift
.package(url: "https://github.com/nodes-vapor/keychain.git", from: "2.0.0")
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
These are the steps required to use Keychain in your project.
1. Define a Payload that conforms to the `KeychainPayload` protocol
2. Create `KeychainConfig` objects for the key types you would like to use
3. Configure your `Keychain` using a `Signer` and the `KeychainConfig` objects defined in step 2
4. Actually start using your `Keychain`

Time to look at each step in detail.

### Define a Payload

Your payload must conform to the  `KeychainPayload` protocol, meaning that it must contain:
- `init(expirationDate: Date, user: User) throws`
- `func findUser(request: Request) -> EventLoopFuture<User>` which is where you do a search for the user you were presented in the `init` method
- `func verify(using signer: JWTSigner) throws` which will verify that your token is still valid

Furthermore you need to tell your `KeychainPayload` what its `associatedtype` for `User` translates to.

Here is an example that uses elements from a JWT token and verifies that the expiration (`exp`) claim is not expired. Note that `findUser` in this case only returns a test user. In real life you probably want to do a lookup somewhere where users are stored.

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
        try exp.verifyNotExpired()
    }
}
```

### Create `KeychainConfig` Objects

Your `KeychainConfig` objects must contain:
- an identifier (eg: access, refresh or reset): `jwkIdentifier`
- an `expirationTimeInterval`

And you need to connect your `KeychainConfig` with the `KeychainPayload` you defined in step 1 (the `KeychainConfig` has a `typealias` for a `KeychainPayload`).

Here is an example creating three `KeychainConfig` objects:
- A `UserAccessKeychainConfig` with the identifier "access" and an `expirationTimeInterval` of 300 seconds
- A `UserRefreshKeychainConfig` with the identifier "refresh" and an `expirationTimeInterval` of 600 seconds
- A `UserResetKeychainConfig` with the identifier "reset" and an `expirationTimeInterval` of 400 seconds

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

### Configure your `Keychain`

Time to tie it all together! In your `configure.swift` you can add multiple `KeychainConfig` objects as seen here:

```swift
app.keychain.configure(
    signer: .hs256(key: YourKeyGoesHere...ProbablyReadFromSomeEnvironment),
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

Note the `signer` parameter. You can use one of the built-in signers as in the first example where we use the `.hs256` signer with a key. Alternatively, you can provide your own signer as it is done in the last two examples.

### Actually start using your `Keychain`

With all the setup out of the way, it is time to kick back and take advantage of `Keychain`. You can now use the `UserAccessKeychainConfig`, `UserRefreshKeychainConfig` and `UserResetKeychainConfig` objects that you created previously to generate JWT tokens by calling the `makeToken(on:, currentDate:)`

Here is an example on how to generate a new `refreshToken`.

```swift
import Keychain

struct UserController {
    let currentDate: () -> Date

    ...

    func refreshToken(request: Request) throws -> Response {
        let token = try UserRefreshKeychainConfig.makeToken(on: request, currentDate: currentDate())

        // here we encode the token string as JSON but you might include your token in a struct
        // conforming to `Content`
        let response = Response()
        try response.content.encode(token, as: .json)
        return response
    }
}
```

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Monstarlab](https://monstar-lab.com/global/).

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
