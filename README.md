<!--
                  
This source file is part of the XCTestExtensions open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

# XCTestExtensions

[![Build and Test](https://github.com/StanfordBDHG/XCTestExtensions/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordBDHG/XCTestExtensions/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/XCTestExtensions/branch/main/graph/badge.svg?token=dF75iJxl45)](https://codecov.io/gh/StanfordBDHG/XCTestExtensions)
[![DOI](https://zenodo.org/badge/597215549.svg)](https://zenodo.org/badge/latestdoi/597215549)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FXCTestExtensions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordBDHG/XCTestExtensions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FXCTestExtensions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordBDHG/XCTestExtensions)

XCTestExtensions is a collection of extensions for commonly used functionality in UI tests using XCTest.


## How To Use XCTestExtensions

You can use XCTestExtensions in your UI tests. The [API documentation](https://swiftpackageindex.com/StanfordBDHG/XCTestExtensions/documentation) provides a detailed overview of the public interface of XCTestExtensions.

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
```swift
let app = XCUIApplication()

let textField = app.textFields["TextField"]
textField.enter(value: "Example Text")
textField.delete(count: 5)

let secureTextField = app.secureTextFields["SecureField"]
secureTextField.enter(value: "Secure Text")
secureTextField.delete(count: 5)
```

Unfortunately, the iOS simulator sometimes has flaky behavior when entering text in a simulator with low computation resources.
The `enter(value:)` and `delete(count:)` methods provide the `checkIfTextWasEnteredCorrectly` and `checkIfTextWasDeletedCorrectly` parameters that are set to true by default to check if the values were entered correctly. If your text entry does fail to do so, e.g., an entry in a secure text field, set the `checkIfTextWasEnteredCorrectly` or `checkIfTextWasDeletedCorrectly` parameters to `false`. 


## Installation

The project can be added to your Xcode project or Swift Package using the [Swift Package Manager](https://github.com/apple/swift-package-manager).

**Xcode:** For an Xcode project, follow the instructions on [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

**Swift Package:** You can follow the [Swift Package Manager documentation about defining dependencies](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#defining-dependencies) to add this project as a dependency to your Swift Package.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordBDHG/XCTestExtensions/tree/main/LICENSES) for more information.


## Contributors

This project is developed as part of the Stanford Byers Center for Biodesign at Stanford University.
See [CONTRIBUTORS.md](https://github.com/StanfordBDHG/XCTestExtensions/tree/main/CONTRIBUTORS.md) for a full list of all XCTestExtensions contributors.

![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-light.png#gh-light-mode-only)
![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-dark.png#gh-dark-mode-only)
