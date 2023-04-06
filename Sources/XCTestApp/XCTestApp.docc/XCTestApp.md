# ``XCTestApp``

<!--
                  
This source file is part of the XCTestExtensions open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

XCTestExtensions is a collection of ...

Swift Packages tests are not capable to test user interface elements or test iOS features that are only available when code runs in an application, e.g., HealthKit, the Secure Enclave, and more.
You can use XCTestApp in an app that tests framework functionality and verifies them using UI tests.

The framework has the following functionalities:


### TestAppTestCase

A ``TestAppTestCase`` is the base type that can be used to implement tests as part of a test application.

The following example demonstrates the usage of a combination of throwing and async test that use ``XCTAssert(_:message:file:line:)``, ``XCTAssertEqual(_:_:message:file:line:)``, ``XCTAssertNil(_:message:file:line:)``, and ``XCTUnwrap(_:message:file:line:)``
that are also included in the `XCTestApp` target.

```swift
struct ExampleTestCaseTest: TestAppTestCase {
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
```
