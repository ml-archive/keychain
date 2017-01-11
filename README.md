# JWT Keychain
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/jwt-keychain.svg?branch=master)](https://travis-ci.org/nodes-vapor/jwt-keychain)
[![codecov](https://codecov.io/gh/nodes-vapor/jwt-keychain/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/jwt-keychain)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/jwt-keychain/master/LICENSE)


This package aims to provide developer with an easy way to scaffhold their API
using a JWT Keychain.

**ATTENTION:** This is a very raw experiment that needs to be tested and validated.

#Installation

#### Config
Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/jwt-keychain.git", majorVersion: 0)
```

Create config jwt.json

```
{
    "secondsToExpire": 3600,
    "signatureKey": "our-little-secret"
}
```

### main.swift

```
import Auth
import JWTKeychain
```

Add the AuthMiddleware with the User model

Add JWTAuthMiddleware & AuthMiddleware  to your API groups

```swift
drop.group(AuthMiddleware<User>(), JWTAuthMiddleware(drop: drop)) { jwtRoutes in
     //Routes
}
```

This package also provides a User model and some user endpoints that can be used out of the box.

To register the existing user routes, add this to the main.swift
```swift
// Setup routes
UserRoutes().register(drop: drop)
```

The aim is to encode the user identifier on the SubjectClaim of the JWT. This way we don't
need to keep track of the user's tokens on the database. The tokens generated are signed by
the key setup on the config file.

We just need to verify the token signature and its claims.

Currently provided endpoints are:

- Login: `POST api/v1/users/login`
- Register: `POST api/v1/users`
- Logout: `GET api/v1/users/logout`
- Token regenerate: `GET api/v1/users/token/regenerate`
- Me: `GET api/v1/users/me`
