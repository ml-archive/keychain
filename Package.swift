// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JWTKeychain",
    products: [
        .library(name: "JWTKeychain", targets: ["JWTKeychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/nodes-vapor/sugar.git", .branch("vapor-3")),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "JWTKeychain", 
            dependencies: [
                "Authentication",
                "JWT",
                "Sugar",
                "Vapor"
            ]
        ),
        .testTarget(name: "JWTKeychainTests", dependencies: ["JWTKeychain"])
    ]
)
