//
// This source file is part of the XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import XCTestExtensions


class TestAppUITests: XCTestCase {
    func testDeleteAndLaunch() throws {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        XCTAssert(app.staticTexts["No text set ..."].waitForExistence(timeout: 5.0))
        XCTAssert(app.staticTexts["No secure text set ..."].waitForExistence(timeout: 5.0))
    }
    
    func testDeleteAndLaunchFromFirstPage() throws {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        springboard.swipeRight()
        
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        XCTAssert(app.staticTexts["No text set ..."].waitForExistence(timeout: 5.0))
        XCTAssert(app.staticTexts["No secure text set ..."].waitForExistence(timeout: 5.0))
    }
    
    func testDisablePasswordAutofill() throws {
        try disablePasswordAutofill()
    }
    
    func testTextEntry() throws {
        let app = XCUIApplication()
        app.launch()
        
        simulateFlakySimulatorTextEntry = false
        try app.callTextEntryExtensions()
    }
    
    func testFlakyTextEntry() throws {
        let app = XCUIApplication()
        app.launch()
        
        simulateFlakySimulatorTextEntry = true
        try app.callTextEntryExtensions()
    }
}


extension XCUIApplication {
    fileprivate func callTextEntryExtensions() throws {
        XCTAssert(staticTexts["No text set ..."].waitForExistence(timeout: 5.0))
        let textField = textFields["TextField"]
        try textField.enter(value: "Example Text")
        XCTAssert(staticTexts["Example Text"].waitForExistence(timeout: 5.0))
        try textField.delete(count: 5)
        XCTAssert(staticTexts["Example"].waitForExistence(timeout: 5.0))
        
        try textField.delete(count: 42)
        XCTAssert(staticTexts["No text set ..."].waitForExistence(timeout: 5.0))
        
        swipeUp()
        
        XCTAssert(staticTexts["No secure text set ..."].waitForExistence(timeout: 5.0))
        let secureTextField = secureTextFields["SecureField"]
        try secureTextField.enter(value: "Secure Text")
        XCTAssert(staticTexts["Secure Text"].waitForExistence(timeout: 5.0))
        try secureTextField.delete(count: 5)
        XCTAssert(staticTexts["Secure"].waitForExistence(timeout: 5.0))
        
        try secureTextField.delete(count: 42)
        XCTAssert(staticTexts["No secure text set ..."].waitForExistence(timeout: 5.0))
    }
}
