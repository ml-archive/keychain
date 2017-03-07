# JWT Keychain
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/jwt-keychain.svg?branch=master)](https://travis-ci.org/nodes-vapor/jwt-keychain)
[![codecov](https://codecov.io/gh/nodes-vapor/jwt-keychain/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/jwt-keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/jwt-keychain/master/LICENSE)


This package aims to provide developer with an easy way to scaffhold their API
using a JWT Keychain.

**ATTENTION:** This is a very raw experiment that needs to be tested and validated.

## Demo project
https://github.com/nodes-vapor/jwt-keychain-demo

## Installation

Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/jwt-keychain.git", majorVersion: 0)
```

Add Vapor forms as provider in main.swift
```swift
import VaporForms
try drop.addProvider(VaporForms.Provider.self)
```
Create config jwt.json with:

signer[HS256, HS384, HS512] + secondsToExpire + signatureKey

or

signer[ES256, ES384, ES512, RS256, RS384, RS512] + secondsToExpire + signatureKey + publicKey

Create config `jwt.json`
```json
{
    "signer": "HS256",
    "secondsToExpire": 3600,
    "signatureKey": "our-little-secret",
    "resetPasswordEmail": "path/to/email/iew",
    "secondsToExpireResetPassword": 3600
}
```

Create config `mail.json`
```swift
{
    "smtpHost": "TODO",
    "smtpPort": "TODO",
    "user": "TODO",
    "password": "TODO",
    "fromEmail": "TODO@todo.com",
    "fromName": "TODO"
}

```
Copy package resources
`/Packages/JWTKeyChainX.Y.Z/Resource/Views to /Resource/Views`

See https://github.com/vapor/vapor-jwt to know more about signing

Import the module whenever needed:

```swift
import JWTKeychain
```

## Getting started 🚀

### Minimal setup

Register the basic user routes

```swift
let configuration = try JWTKeychain.Configuration(drop: drop)

drop.collection(
    try ApiUserRoutes<User>(
        drop: drop,
        mailer: Mailer(configuration: configuration, drop: drop)
    )
)
```

That's it! Now, you'll have the following routes out-of-the-box:

- Login: `POST /users/login`
- Register: `POST /users`
- Logout: `GET /users/logout`
- Token regenerate: `PATCH /users/token/regenerate`
- Me: `GET /users/me`

### Customized setup

If you want to roll out your own routes or have more control over the controller logic, you can initialize the routes like this:

```swift
let configuration = try JWTKeychain.Configuration(drop: drop)
let jwtAuthMiddleware = JWTKeychain.AuthMiddleware(configuration: configuration)
let authMiddleware = Auth.AuthMiddleware<MyCustomUser>()
let userController = MyUserController(configuration: configuration)

drop.collection(
    try ApiUserRoutes<JWTKeychain.User>(
        drop: drop,
        configuration: configuration,
        jwtAuthMiddleware: jwtAuthMiddleware,
        authMiddleware: authMiddleware,
        userController: userController,
        mailer: Mailer(configuration: configuration, drop: drop)
    )
)
```

Most of the parameters have default values, so feel free to mix and match as needed.


## Customization 
`JWTKeychain` provides protocols for rolling out your own `User` models and controllers.

### The UserType protocol
```swift
public protocol UserType: Auth.User, Model {
    associatedtype Validator: Form
    
    var name: String? { get set }
    var email: String { get set }
    var password: String { get set }
    
    // optional
    var createdAt: Date? { get set }
    // optional
    var updatedAt: Date? { get set }
    // optional
    var deletedAt: Date? { get set }
    
    init(validated: Validator)
    
    // optional
    func makeJSON(token: String) throws -> JSON
    // optional
    func makeJWTNode() throws -> Node
}
```
`Validator` is a typealias for the `Form` you wish to instantiate and validate the incoming request with. The fields `createdAt`, `updatedAt`, and `deletedAt` and the functions `makeJSON(token: String)` and `func makeJWTNode()` are all optional and have a default implementations.

### The UserControllerType protocol
If you wish to modify the behavior of the `BasicUserController` you can simply extend it and override any function you wish. If you're wanting to create your own UserController from scratch you can conform to the following protocol:
```swift
public protocol UserControllerType {
    init(configuration: ConfigurationType, drop: Droplet, mailer: MailerType)

    func register(request: Request) throws -> ResponseRepresentable

    func login(request: Request) throws -> ResponseRepresentable

    func logout(request: Request) throws -> ResponseRepresentable

    func regenerate(request: Request) throws -> ResponseRepresentable

    func me(request: Request) throws -> ResponseRepresentable
    
    func resetPasswordEmail(request: Request) throws -> ResponseRepresentable

    func resetPasswordForm(request: Request, token: String) throws -> View

    func resetPasswordChange(request: Request) throws -> Response
}
```

## 🏆 Credits
This package is developed and maintained by the Vapor team at [Nodes](https://www.nodes.dk).

## 📄 License
This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
