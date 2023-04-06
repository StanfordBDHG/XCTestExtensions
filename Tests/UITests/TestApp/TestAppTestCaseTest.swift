//
// This source file is part of the XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import XCTestApp


struct TestAppTestCaseTest: TestAppTestCase {
    func runTests() async throws {
        try testAssert()
        try await testAssertEqual()
        try await testAssertNil()
        try testAssertUnwrap()
    }
    
    private func testAssert() throws {
        try XCTAssert(true)
        
        do {
            try XCTAssert(false)
            throw XCTestFailure(message: "Did not trigger the expected assertion.")
        } catch { }
    }
    
    private func testAssertEqual() async throws {
        try await Task.sleep(for: .seconds(0.1))
        
        
        try XCTAssertEqual(42, 42)
        
        do {
            try XCTAssertEqual(42, 43)
            throw XCTestFailure(message: "Did not trigger the expected assertion.")
        } catch { }
    }
    
    private func testAssertNil() async throws {
        try XCTAssertNil(Optional<Int>.none)
        
        do {
            try XCTAssertNil(42)
            throw XCTestFailure(message: "Did not trigger the expected assertion.")
        } catch { }
        
        
        try await Task.sleep(for: .seconds(0.1))
    }
    
    private func testAssertUnwrap() throws {
        print(try XCTUnwrap(42))
        
        do {
            _ = try XCTUnwrap(Optional<Int>.none)
            throw XCTestFailure(message: "Did not trigger the expected assertion.")
        } catch { }
    }
}
