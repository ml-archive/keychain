import PackageDescription

let package = Package(
    name: "JWTKeychain",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/mysql-provider.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/jwt-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/bcrypt.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/nodes-vapor/sugar.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/nodes-vapor/flash.git", Version(1,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
