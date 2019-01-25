// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TILApp",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2"),
        
        // Specify FluentPostgreSQL as a package dependency,Specify that the App target depends on FluentPostgreSQL to ensure it links correctly.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        // Specify FluentMySQL as a package dependency,Specify that the App target depends on FluentMySQL to ensure it links correctly.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "FluentPostgreSQL", "FluentMySQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

