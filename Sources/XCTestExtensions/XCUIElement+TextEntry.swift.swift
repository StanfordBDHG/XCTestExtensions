//
// This source file is part of the XCTestExtensions open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


/// An internal flag that is used to test the flaky simulator text entry behaviour in the iOS simulator.
///
/// Do not use this flag outside of the UI tests in the ``XCTestExtensions`` target!
var simulateFlakySimulatorTextEntry = false


extension XCUIElement {
    /// Delete a fixed number of characters in a text field or secure text field.
    /// - Parameter count: The number of characters that should be deleted.
    /// - Parameter checkIfTextWasDeletedCorrectly: Check if the text was deleted correctly.
    ///
    /// Unfortunately, the iOS simulator sometimes has flaky behavior when entering text in a simulator with low computation resources.
    /// The method provides the `checkIfTextWasDeletedCorrectly` parameter that is set to true by default to check if the characters were deleted correctly.
    /// If your text entry does fail to do so, e.g., a deletion in a secure text field, set the `checkIfTextWasDeletedCorrectly` parameter to `false`.
    public func delete(count: Int, checkIfTextWasDeletedCorrectly: Bool = true) {
        delete(count: count, checkIfTextWasDeletedCorrectly: checkIfTextWasDeletedCorrectly, recursiveDepth: 0)
    }
    
    /// Type a text in a text field or secure text field.
    /// - Parameter newValue: The text that should be typed.
    /// - Parameter checkIfTextWasEnteredCorrectly: Check if the text was entered correctly.
    ///
    /// Unfortunately, the iOS simulator sometimes has flaky behavior when entering text in a simulator with low computation resources.
    /// The method provides the `checkIfTextWasEnteredCorrectly` parameter that is set to true by default to check if the characters were entered correctly.
    /// If your text entry does fail to do so, e.g., an entry in a secure text field, set the `checkIfTextWasEnteredCorrectly` parameter to `false`.
    public func enter(value newValue: String, checkIfTextWasEnteredCorrectly: Bool = true) {
        enter(value: newValue, checkIfTextWasEnteredCorrectly: checkIfTextWasEnteredCorrectly, recursiveDepth: 0)
    }
    
    
    private func delete( // swiftlint:disable:this function_default_parameter_at_end
        count: Int,
        checkIfTextWasDeletedCorrectly: Bool = true,
        // We put this paramter at the end of the function to mimic the public interface with an internal extension.
        recursiveDepth: Int
    ) {
        guard recursiveDepth <= 2 else {
            XCTFail("Could not successfully delete \(count) characters in the textfield \(self.debugDescription)")
            return
        }
        
        // Get the current value so we can assert if the text deleted was correct.
        let currentValueCount: Int
        if value as? String == placeholderValue {
            // If the value is the placeholderValue we assume that the text field has no value entered.
            currentValueCount = 0
        } else {
            currentValueCount = (value as? String ?? "").count
        }
        
        coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.5)).tap()
        XCTAssert(XCUIApplication().keyboards.firstMatch.waitForExistence(timeout: 2.0))
        if simulateFlakySimulatorTextEntry && recursiveDepth < 2 {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: count - 1))
        } else {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: count))
        }
        
        // Check of the text was deleted correctly:
        if checkIfTextWasDeletedCorrectly {
            let countAfterDeletion = (value as? String ?? "").count
            
            if currentValueCount - count < countAfterDeletion {
                delete(
                    count: countAfterDeletion - (currentValueCount - count),
                    checkIfTextWasDeletedCorrectly: true,
                    recursiveDepth: recursiveDepth + 1
                )
            }
        }
    }
    
    private func enter( // swiftlint:disable:this function_default_parameter_at_end
        value textToEnter: String,
        checkIfTextWasEnteredCorrectly: Bool = true,
        // We put this paramter at the end of the function to mimic the public interface with an internal extension.
        recursiveDepth: Int
    ) {
        guard recursiveDepth <= 2 else {
            XCTFail("Could not successfully verify entering \"\(textToEnter)\" in the textfield \(self.debugDescription)")
            return
        }
        
        // Get the current value so we can assert if the text entry was correct.
        let currentValue: String
        if value as? String == placeholderValue {
            // If the value is the placeholderValue we assume that the text field has no value entered.
            currentValue = ""
        } else {
            currentValue = value as? String ?? ""
        }
        
        // Enter the value
        coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.5)).tap()
        XCTAssert(XCUIApplication().keyboards.firstMatch.waitForExistence(timeout: 2.0))
        if simulateFlakySimulatorTextEntry && recursiveDepth < 2 {
            typeText(String(textToEnter.dropLast(1)))
        } else {
            typeText(textToEnter)
        }
        
        // Check of the text was entered correctly:
        if checkIfTextWasEnteredCorrectly {
            let valueAfterTextEntry = value as? String ?? ""
            
            if self.elementType == .secureTextField {
                if currentValue.isEmpty && textToEnter.count != valueAfterTextEntry.count {
                    // We delete the text twice to ensure that we have an empty text field even if the textfield might go byeond the current scope
                    delete(count: valueAfterTextEntry.count, checkIfTextWasDeletedCorrectly: false)
                    delete(count: valueAfterTextEntry.count, checkIfTextWasDeletedCorrectly: false)
                    
                    enter(
                        value: currentValue + textToEnter,
                        checkIfTextWasEnteredCorrectly: true,
                        recursiveDepth: recursiveDepth + 1
                    )
                } else if currentValue.count + textToEnter.count != valueAfterTextEntry.count {
                    XCTFail(
                        """
                        The text entered in the secure text field doesn't seem to match the desired length.
                        We can not re-enter the value as we don't have an insight into the value that was present in the secure text field before.
                        """
                    )
                }
            } else {
                if currentValue + textToEnter != valueAfterTextEntry {
                    // We delete the text twice to ensure that we have an empty text field even if the textfield might go byeond the current scope
                    delete(count: valueAfterTextEntry.count, checkIfTextWasDeletedCorrectly: false)
                    delete(count: valueAfterTextEntry.count, checkIfTextWasDeletedCorrectly: false)
                    
                    enter(
                        value: currentValue + textToEnter,
                        checkIfTextWasEnteredCorrectly: true,
                        recursiveDepth: recursiveDepth + 1
                    )
                }
            }
        }
    }
}
