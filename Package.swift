// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Annotate",
    platforms: [
        .macOS(.v13)  // Adjust as needed
    ],
    products: [
        // An executable product, so SwiftPM tries to compile and link all files under the target.
        .executable(name: "Annotate", targets: ["Annotate"])
    ],
    dependencies: [
        // Declare any package dependencies here.
        // e.g. .package(url: "https://github.com/...", from: "1.2.3")
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "2.2.4")
    ],
    targets: [
        .executableTarget(
            name: "Annotate",
            dependencies: [],
            // 'path' should point to the directory containing your .swift files (AppDelegate.swift, etc.)
            // If those files are in a folder named "Annotate", set `path: "Annotate"`.
            // If everything is in your root directory, you can omit 'path' or set it to "."
            path: "Annotate"
        )
    ]
)
