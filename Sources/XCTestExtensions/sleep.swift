//
// This source file is part of the Stanford XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import func unistd.usleep


/// Sleeps for the specified duration.
///
/// - Note: This exists as a synchronous alternative to `Task.sleep(for:)`, since implementing UI tests as async functions can cause issues with XCTest.
public func sleep(for duration: Duration) {
    usleep(UInt32(duration.timeInterval * 1000000))
}


extension Duration {
    /// The number of seconds in the `Duration`, as a `TimeInterval` value.
    fileprivate var timeInterval: Double {
        let components = self.components
        let attosecondsInSeconds = Double(components.attoseconds) / 1_000_000_000_000_000_000.0 // 10^-18
        return Double(components.seconds) + attosecondsInSeconds
    }
}
