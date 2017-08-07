import PackageDescription

let package = Package(
    name: "JWTKeychain",
    dependencies: [
        .Package(url: "https://github.com/harlanhaskins/Punctual.swift.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 1),
        .Package(url: "https://github.com/siemensikkema/forms.git", majorVersion: 0),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/jwt-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/validation.git", majorVersion: 1),
    ],
    exclude: [
        "Sourcery",
    ]
)
