// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Annotate",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "Annotate", targets: ["Annotate"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.2.4"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Annotate",
            dependencies: ["KeyboardShortcuts", "Sparkle"],
            path: "Annotate",
            resources: [
                .process("Assets.xcassets"),
                .process("Preview Content"),
            ]
        ),
        .testTarget(
            name: "AnnotateTests",
            dependencies: ["Annotate"],
            path: "AnnotateTests"
        ),
    ]
)
