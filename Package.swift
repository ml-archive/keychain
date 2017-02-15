import PackageDescription

let package = Package(
    name: "JWTKeychain",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/siemensikkema/vapor-jwt.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/bygri/vapor-forms.git", majorVersion:0, minor: 5),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 0, minor: 1),
    ]
)
