// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "GraphQL",

    products: [
        .library(name: "GraphQL", targets: ["GraphQL"]),
    ],

    dependencies: [
        .package(url: "https://github.com/jseibert/Runtime.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.0"),
    ],

    targets: [
        .target(name: "GraphQL", dependencies: ["Runtime", "NIO"]),

        .testTarget(name: "GraphQLTests", dependencies: ["GraphQL"]),
    ]
)
