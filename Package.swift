// swift-tools-version:5.7

//
// This source file is part of the XCTestExtensions open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "XCTestExtensions",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "XCTestExtensions", targets: ["XCTestExtensions"])
    ],
    targets: [
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
