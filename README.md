# JWT Keychain
[![Swift Version](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![Linux Build Status](https://img.shields.io/circleci/project/github/nodes-vapor/jwt-keychain.svg?label=Linux)](https://circleci.com/gh/nodes-vapor/jwt-keychain)
[![macOS Build Status](https://img.shields.io/travis/nodes-vapor/jwt-keychain.svg?label=macOS)](https://travis-ci.org/nodes-vapor/jwt-keychain)
[![codebeat badge](https://codebeat.co/badges/52c2f960-625c-4a63-ae63-52a24d747da1)](https://codebeat.co/projects/github-com-nodes-vapor-jwt-keychain)
[![codecov](https://codecov.io/gh/nodes-vapor/jwt-keychain/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/jwt-keychain)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/jwt-keychain)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/jwt-keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/jwt-keychain/master/LICENSE)

This package aims to provide developers with an easy way to scaffold their API using a JWT Keychain.

## Demo project

https://github.com/nodes-vapor/jwt-keychain-demo

## 📦 Installation

Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/jwt-keychain.git", majorVersion: 0)
```

## Getting started 🚀

### Configuration

Create config `jwt.json` (for more information, see [JWTProvider](https://github.com/vapor/jwt-provider).

```json
{
	"signers": [
		{
			"type": "rsa",
			"kid": "access",
			"algorithm: "rs256",
			"key": "yourkeyhere"
		},
		{
			"type": "rsa",
			"kid": "refresh",
			"algorithm: "rs256",
			"key": "yourkeyhere"
		},
		{
			"type": "rsa",
			"kid": "reset",
			"algorithm: "rs256",
			"key": "yourkeyhere"
		}
	]
}
```

Create config `jwt-keychain.json`.

```json
{
	"apiAccess": {
		"kid": "access",
		"secondsToExpire": 3600,
	},
	"refreshToken": {
		"kid": "refresh",
		"secondsToExpire": 31536000
	},
	"resetPassword": {
		"kid": "reset",
		"secondsToExpire": 3600,
		"fromName": "Name of Sender",
		"fromAddress": "sender@email.com",
		"pathToEmail": "Emails/resetPassword",
		"pathToView": "Views/resetPassword"
	}
}
```

The `kid` values should correspond to values in `jwt.json`. The above values are the defaults used when no configuration is supplied; only `resetPassword.fromName` and `resetPassword.fromAddress`.

JWTKeychainProvider uses the default mailer as configured in `mail.json` for sending password reset emails.

Make sure url is set up in `app.json`. This will be used to generate the link in the password reset email.

```json
{
    "url": "https://example.com"
}
```

### Token Generator Command
In order to generate password reset tokens for users add the following to `droplet.json`'s `commands`: `"keychain:generate_token"`. Then you can create a token like so: 

```drop --run keychain:generate_token user@email.com```

### Resources

Copy package resources
`/Packages/JWTKeyChainX.Y.Z/Resources/Views to /Resource/Views`

See https://github.com/vapor/vapor-jwt to know more about signing.

### Usage

Import the module whenever needed:

```swift
import JWTKeychain
```

```swift
try config.addProvider(AdminPanelProvider.Provider.self)
```

That's it! Now, you'll have the following routes out-of-the-box:

- Login: `POST /users/login`
- Register: `POST /users`
- Logout: `GET /users/logout`
- Token regenerate: `PATCH /users/token/regenerate`
- Me: `GET /users/me`
- Reset password: `POST /users/reset-password/request`

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

### UserController
If you wish to modify the behavior of the `UserController` you can subclass it and override any function you wish. If you want to create your own UserController from scratch you can conform to the 'UserControllerType` protocol.

### PasswordResetMailer

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema/).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
