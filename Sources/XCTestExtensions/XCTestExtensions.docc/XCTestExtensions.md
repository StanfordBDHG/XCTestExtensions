# ``XCTestExtensions``

<!--
                  
This source file is part of the Stanford XCTestExtensions open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

XCTestExtensions is a collection of extensions for commonly used functionality in UI tests using XCTest.

You can use XCTestExtensions in your UI tests.
The framework has the following functionalities:


### Delete & Launch Application

Delete and launch the application. Use this function to completely reset the application, e.g., for system permission screens and alerts.
```swift
let app = XCUIApplication()
app.deleteAndLaunch(withSpringboardAppName: "TestApp")
```


### Disable Password Autofill

The iOS Simulator has enabled password autofill by default, which can interfere with text entry in password fields in UI tests. The `XCTestCase` extension provides the `disablePasswordAutofill` to navigate to the settings app and disable password autofill.
```swift
class TestAppUITests: XCTestCase {
    func testDeleteAndLaunch() throws {
        disablePasswordAutofill()
        
        // ...
    }
}
```


### Text Entry

Allows a simple extension on `XCUIElement` to delete and type text in a text field or secure text field.
Use the `dismissKeyboard` method of the `XCUIApplication` type to dismiss the keyboard between entering information in textfield.
```swift
let app = XCUIApplication()

let textField = app.textFields["TextField"]
textField.enter(value: "Example Text")
textField.delete(count: 5)

app.dismissKeyboard()

let secureTextField = app.secureTextFields["SecureField"]
secureTextField.enter(value: "Secure Text")
secureTextField.delete(count: 5)
```

Unfortunately, the iOS simulator sometimes has flaky behavior when entering text in a simulator with low computation resources.
The `enter(value:)` and `delete(count:)` methods provide the `checkIfTextWasEnteredCorrectly` and `checkIfTextWasDeletedCorrectly` parameters that are set to true by default to check if the values were entered correctly. If your text entry does fail to do so, e.g., an entry in a secure text field, set the `checkIfTextWasEnteredCorrectly` or `checkIfTextWasDeletedCorrectly` parameters to `false`. 
