// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JWTKeychain",
    products: [
        .library(name: "JWTKeychain", targets: ["JWTKeychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "JWTKeychain", 
            dependencies: [
                "Authentication",
                "FluentMySQL",
                "JWT",
                "Sugar",
                "Vapor"
            ]
        ),
        .testTarget(name: "JWTKeychainTests", dependencies: ["JWTKeychain"])
    ]
)
