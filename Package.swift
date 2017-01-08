import PackageDescription

let package = Package(
    name: "jwt-keychain",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", majorVersion: 0),
        .Package(url: "https://github.com/siemensikkema/vapor-jwt.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Skyback/vapor-forms.git", majorVersion:0, minor: 3),
    ]
)
