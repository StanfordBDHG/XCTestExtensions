// swift-tools-version:6.0

//
// This source file is part of the Stanford XCTestExtensions open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


let package = Package(
    name: "XCTestExtensions",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
        .macOS(.v13)
    ],
    products: [
        .library(name: "XCTestApp", targets: ["XCTestApp"]),
        .library(name: "XCTestExtensions", targets: ["XCTestExtensions"])
    ],
    dependencies: [] + swiftLintPackage(),
    targets: [
        .target(
            name: "XCTestApp",
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "XCTestExtensions",
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "XCTestExtensionsTests",
            dependencies: [
                .target(name: "XCTestExtensions")
            ],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
