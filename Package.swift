// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-terminal-input-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Terminal Input Primitives",
            targets: ["Terminal Input Primitives"]
        ),
        .library(
            name: "Terminal Input Primitives Test Support",
            targets: ["Terminal Input Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-terminal-primitives"),
        .package(path: "../swift-input-primitives"),
        .package(path: "../swift-ascii-primitives"),
    ],
    targets: [
        .target(
            name: "Terminal Input Primitives",
            dependencies: [
                .product(name: "Terminal Primitives Core", package: "swift-terminal-primitives"),
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
            ]
        ),
        .target(
            name: "Terminal Input Primitives Test Support",
            dependencies: [
                "Terminal Input Primitives",
                .product(name: "Input Primitives Test Support", package: "swift-input-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Terminal Input Primitives Tests",
            dependencies: [
                "Terminal Input Primitives",
                "Terminal Input Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
