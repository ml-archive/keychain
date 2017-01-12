# JWT Keychain
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/jwt-keychain.svg?branch=master)](https://travis-ci.org/nodes-vapor/jwt-keychain)
[![codecov](https://codecov.io/gh/nodes-vapor/jwt-keychain/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/jwt-keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/jwt-keychain/master/LICENSE)


This package aims to provide developer with an easy way to scaffhold their API
using a JWT Keychain.

**ATTENTION:** This is a very raw experiment that needs to be tested and validated.

## Installation

Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/jwt-keychain.git", majorVersion: 0)
```

Create config jwt.json with:

signer[HS256, HS384, HS512] + secondsToExpire + signatureKey

or

signer[ES256, ES384, ES512, RS256, RS384, RS512] + secondsToExpire + signatureKey + publicKey

```

Create config `jwt.json`
```json

{
    "signer": "HS256",
    "secondsToExpire": 3600,
    "signatureKey": "our-little-secret"
}
```
See https://github.com/siemensikkema/vapor-jwt to know more about signing

Import the module whenever needed:

```swift
import JWTKeychain
```

## Getting started 🚀
Setup provider
```swift
try drop.addProvider(JWTKeychain.Provider.self)
```

Register user routes

```swift
drop.collection(UserRoutes(drop: drop))
```

That's it, now you'll have the following routes out-of-the-box:

- Login: `POST /users/login`
- Register: `POST /users`
- Logout: `GET /users/logout`
- Token regenerate: `PATCH /users/token/regenerate`
- Me: `GET /users/me`

If you want to roll out your own routes, then have a look at `UserRoutes.swift` for inspiration and apply the middleware as needed, e.g.

```swift
// Setup routes
try UserRoutes().register(drop: drop)

```

The aim is to encode the user identifier on the SubjectClaim of the JWT. This way we don't
need to keep track of the user's tokens on the database. The tokens generated are signed by
the key setup on the config file.

We just need to verify the token signature and its claims.

## 🏆 Credits
This package is developed and maintained by the Vapor team at [Nodes](https://www.nodes.dk).

## 📄 License
This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
