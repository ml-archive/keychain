import PackageDescription

let package = Package(
    name: "JWTKeychain",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/jwt-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/validation.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", majorVersion: 2),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 1)
    ]
)
