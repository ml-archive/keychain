import PackageDescription

let package = Package(
    name: "JWTKeychain",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 2),
        // TODO: update url once PR is accepted
        .Package(url: "https://github.com/siemensikkema/jwt-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/bcrypt.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", majorVersion: 2),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 1)
    ]
)
