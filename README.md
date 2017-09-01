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
	"signers": {
		"access": {
			"type": "hmac",
			"algorithm": "hs256",
			"key": "yourkeyhere"
		},
		"refresh": {
			"type": "hmac",
			"algorithm": "hs256",
			"key": "yourkeyhere"
		},
		"reset": {
			"type": "hmac",
			"algorithm": "hs256",
			"key": "yourkeyhere"
		}
	}
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

The `kid` values should correspond to values in `jwt.json`. The above values for `apiAccess` and `resetPassword` are the defaults used when no configuration is supplied; only `resetPassword.fromName` and `resetPassword.fromAddress` are required.

Usage of a refresh token is optional. You can opt out of using the refresh token by removing the `refreshToken` key.

JWTKeychainProvider uses the default mailer as configured in `mail.json` or `mailgun.json`
 for sending password reset emails.

Make sure a value for the key `url` is provided in `app.json`. This will be used to generate the link in the password reset email.

```json
{
    "url": "https://example.com"
}
```

JWTKeychain uses Leaf to render the password reset email and form. Make sure Leaf is set up by adding `"view": "leaf"` to `droplet.json` and add the LeafProvider:

```swift
try addProvider(LeafProvider.Provider.self)
```

### Resources

Copy package resources:

`JWTKeychain/Resources/Views` to `/Resource/Views`.

See `https://github.com/vapor/vapor-jwt` to learn more about signing.

### Usage

Add the provider (preferably in `setupProviders()` in `Config+Setup.swift`):

```swift
import JWTKeychain
```

```swift
try addProvider(JWTKeychain.Provider.self)
```

That's it! Now, you'll have the following routes out-of-the-box:

- Login: `POST /users/login`
- Register: `POST /users`
- Logout: `GET /users/logout`
- Token regenerate: `PATCH /users/token/regenerate`
- Me: `GET /users/me`
- Reset password: `POST /users/reset-password/request`

### Token Generator Command
In order to generate password reset tokens for users add the following to `droplet.json`'s `commands`: `"keychain:generate_token"`. Then you can create a token like so:

> `drop --run keychain:generate_token user@email.com`

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

## Tokens
There are three types of tokens used by JWTKeychain: refresh tokens, API access tokens, and password reset tokens.

Both refresh and access tokens should be included in the `Authorization` header for each request they are needed for, as follows: `Authorization: Bearer TOKEN` (where `TOKEN` is replaced with the actual token string).

### Refresh Tokens

> Usage of this type of token is optional but recommended for extra security. You can opt-out of using refresh tokens by omitting the value for `refreshToken` in `jwt-keychain.json`.

Refresh tokens are tokens with a long expiration time that can be used to generate the more short-lived access tokens that are needed for API access.

Refresh tokens are returned when logging in and when signing up* as a string under the key: `refreshToken`. They can only be used to create new access tokens at the `/users/regenerate` endpoint.

When a refresh token expires a new one can be generated by logging in using the user's credentials.

\* Besides the refresh token, an access token and the user object are also returned as a convenience to the client developer.

### API Access Tokens

API Access tokens give access to the following endpoints:
* GET `/users/me`
* GET `/users/logout`
* PATCH `/users/update`

as well as the endpoints

Whenever an access token is expired a new one can be generated using a request to `/users/regenerate`.

### Password Reset Tokens


## Customization

### UserController
If you wish to modify the behavior of the `UserController` you can subclass it and override any function you wish. If you want to create your own UserController from scratch you can conform to the 'UserControllerType` protocol.

### PasswordResetMailer

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema/).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
