// swift-tools-version:5.9

//
// This source file is part of the Stanford XCTestExtensions open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

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
    targets: [
        .target(
            name: "XCTestApp"
        ),
        .target(
            name: "XCTestExtensions"
        ),
        .testTarget(
            name: "XCTestExtensionsTests",
            dependencies: [
                .target(name: "XCTestExtensions")
            ]
        )
    ]
)
