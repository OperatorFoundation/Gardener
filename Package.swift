// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gardener",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Gardener",
            targets: ["Gardener"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Chord", from: "0.0.13"),
        .package(url: "https://github.com/OperatorFoundation/Datable", from: "3.1.1"),
        .package(url: "https://github.com/apple/swift-system", from: "1.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Gardener",
            dependencies: [
                "Chord",
                "Datable",
                .product(name: "SystemPackage", package: "swift-system")
            ]),
        .testTarget(
            name: "GardenerTests",
            dependencies: ["Gardener"]),
    ],
    swiftLanguageVersions: [.v5]
)
