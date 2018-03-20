// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JWTKeychain",
    products: [
        .library(name: "JWTKeychain", targets: ["JWTKeychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/harlanhaskins/Punctual.swift.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/nodes-vapor/flash.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/nodes-vapor/forms.git", .upToNextMinor(from: "0.6.1")),
        .package(url: "https://github.com/nodes-vapor/sugar.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/jwt-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/validation.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "JWTKeychain", 
            dependencies: [
                "Flash",
                "FluentProvider",
                "Forms",
                "JWTProvider",
                "Punctual", 
                "LeafProvider",
                "Sugar",
                "Validation",
                "Vapor"
            ]
        ),
        .testTarget(name: "JWTKeychainTests", dependencies: ["JWTKeychain"])
    ]
)
