// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gardener",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
   ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Gardener",
            targets: ["Gardener"]),
        .executable(name: "GardenerCommandLine", targets: ["GardenerCommandLine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
        .package(url: "https://github.com/apple/swift-system", from: "1.2.1"),

        .package(url: "https://github.com/OperatorFoundation/Chord", branch: "0.1.1"),
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "4.0.0"),
        .package(url: "https://github.com/Bouke/Glob", from: "1.0.5"),
        .package(url: "https://github.com/nerdishbynature/octokit.swift", from: "0.12.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Gardener",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "OctoKit", package: "octokit.swift"),

                "Chord",
                "Datable",
                "Glob",
            ]),
        .executableTarget(
            name: "GardenerCommandLine",
            dependencies: [
                "Gardener",

                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "GardenerTests",
            dependencies: ["Gardener"]),
    ],
    swiftLanguageVersions: [.v5]
)
