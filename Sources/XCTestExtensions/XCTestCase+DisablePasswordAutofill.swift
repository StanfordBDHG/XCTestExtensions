//
// This source file is part of the Stanford XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import XCTest


extension XCTestCase {
    /// Navigate to the iOS settings app and turn off the password autofill functionality.
    ///
    /// The iOS Simulator has the password autofill feature enabled by default, which makes it challenging to write automated UI tests for password fields:
    /// The iOS Simulator does not properly display the password autofill UI, and the UI test can no longer enter text in text fields that contain the autogenerated password with a yellow background.
    ///
    /// Use this function used to to disable password autofill by navigating to the iOS settings app and turning off the password autofill functionality in the settings UI.
    ///
    /// > Warning: While this workaround worked well until 17.2, we experienced a crash of the passwords section in the IOS 17.2 passwords app on the iOS simulator, which no longer allows us to use this workaround.
    /// We recommend using a custom setup script to skip password-related functionality in your UI tests until there is a better workaround. Please inspect the logic to setup simulators in the [xcodebuild-or-fastlane.yml](https://github.com/StanfordBDHG/.github/blob/main/.github/workflows/xcodebuild-or-fastlane.yml) workflow and be sure to `setupSimulators: true` if you use the GitHub action as a reusable workflow.
    @available(
        iOS,
        deprecated: 17.2,
        message: """
                 To avoid having the password autofill interfere with your UI test, \
                 avoid specifying the password text content type for simulator builds.
                 This method will be removed in a future version.
                 """
    )
    @available(watchOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    @MainActor
    public func disablePasswordAutofill() throws {
        let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settingsApp.terminate()
        settingsApp.launch()
        
        XCTAssert(settingsApp.staticTexts["PASSWORDS"].waitForExistence(timeout: 5.0))
        settingsApp.staticTexts["PASSWORDS"].tap()

        if #available(iOS 17.2, *) {
            sleep(2)
            
            guard settingsApp.navigationBars.staticTexts["Passwords"].waitForExistence(timeout: 2.0) else {
                os_log("Could not open the passwords section in the iOS 17.2 simulator due to a bug that immediately closed the passwords section.")
                return
            }
        } else {
            XCTAssert(settingsApp.navigationBars.staticTexts["Passwords"].waitForExistence(timeout: 2.0))
        }
        
        let springboard = XCUIApplication(bundleIdentifier: XCUIApplication.homeScreenBundle)

        sleep(1)
        if springboard.secureTextFields["Passcode field"].exists {
            let passcodeInput = springboard.secureTextFields["Passcode field"]
            passcodeInput.tap()
            
            sleep(2)
            
            passcodeInput.typeText("1234\r")
            
            sleep(2)
        } else if #unavailable(iOS 17.4) {
            // other versions just don't need a passcode anymore
            os_log("Could not enter the passcode in the device to enter the password section in the settings app.")
            throw XCTestError(.failureWhileWaiting)
        }
        
        var counter = 0
        let passwordOptionsCell = settingsApp.tables.cells["PasswordOptionsCell"]
        while !passwordOptionsCell.isHittable || counter > 10 {
            _ = settingsApp.tables.cells["PasswordOptionsCell"].waitForExistence(timeout: 2.0)
            counter += 1
        }
        
        sleep(3)
        
        settingsApp.tables.cells["PasswordOptionsCell"].tap()
        
        let autoFillPasswords: String
        if #available(iOS 17.0, *) {
            autoFillPasswords = "AutoFill Passwords and Passkeys"
        } else {
            autoFillPasswords = "AutoFill Passwords"
        }
        
        XCTAssert(settingsApp.switches[autoFillPasswords].waitForExistence(timeout: 5))
        if settingsApp.switches[autoFillPasswords].value as? String == "1" {
            settingsApp.switches[autoFillPasswords].tap()
        }
    }
}
