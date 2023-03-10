//
// This source file is part of the XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@main
struct UITestsApp: App {
    @State var text: String = ""
    @State var secureText: String = ""
    
    
    var body: some Scene {
        WindowGroup {
            Form {
                Section {
                    TextField("TextField", text: $text)
                    Text(text.isEmpty ? "No text set ..." : text)
                }
                Section {
                    SecureField("SecureField", text: $secureText)
                    Text(secureText.isEmpty ? "No secure text set ..." : secureText)
                }
            }
        }
    }
}
