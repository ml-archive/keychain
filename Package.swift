// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JWTKeychain",
    products: [
        .library(name: "JWTKeychain", targets: ["JWTKeychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2")
    ],
    targets: [
        .target(
            name: "JWTKeychain", 
            dependencies: [
                "Vapor"
            ]
        ),
        .testTarget(name: "JWTKeychainTests", dependencies: ["JWTKeychain"])
    ]
)
