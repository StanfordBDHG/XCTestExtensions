//
// This source file is part of the Stanford XCTestExtensions open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// The bundle identifier for the home screen for the specific platform.
    ///
    /// E.g., `com.apple.springboard` on iOS.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public static var homeScreenBundle: String {
        #if os(visionOS)
        "com.apple.RealityLauncher"
        #elseif os(tvOS)
        "com.apple.pineboard"
        #elseif os(iOS)
        "com.apple.springboard"
        #else
        preconditionFailure("Unsupported platform.")
        #endif
    }
    
    private static var visionOS2: Bool {
        #if os(visionOS)
        if #available(visionOS 2.0, *) {
            true
        } else {
            false
        }
        #else
        false
        #endif
    }

    /// Deletes the application from the iOS springboard (iOS home screen) and launches it after it has been deleted and reinstalled.
    /// - Parameter appName: The name of the application as displayed on the springboard (iOS home screen).
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public func deleteAndLaunch(withSpringboardAppName appName: String) {
        self.delete(app: appName)
        self.launch()
    }
    
    /// Delete the application from the home screen.
    ///
    /// Deletes the application from the iOS Springboard, visionOS RealityLauncher or tvOS Pineboard.
    /// - Parameter appName: The springboard name of the application.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public func delete(app appName: String) { // swiftlint:disable:this function_body_length
        self.terminate()

        let springboard = XCUIApplication(bundleIdentifier: Self.homeScreenBundle)
        
        #if os(visionOS)
        springboard.launch() // springboard is in `runningBackgroundSuspended` state on visionOS. So we need to launch it not just activate
        #else
        springboard.activate()
        #endif
        
        let homeScreenIcons = springboard.otherElements["Home screen icons"].icons

        // There might be multiple apps installed with the same name (e.g., we use "TestApp" a lot), so delete all of them
        while homeScreenIcons[appName].firstMatch.waitForExistence(timeout: 10.0) {
            guard let icon = Self.findVisibleIcon(named: appName, in: homeScreenIcons, on: springboard) else {
                XCTFail("Could not find a visible \"\(appName)\" icon on any home screen page.")
                return
            }

            #if os(visionOS)
            icon.press(forDuration: 1)
            #else
            icon.press(forDuration: 1.5)
            #endif
            
            if XCUIApplication.visionOS2 {
                // VisionOS 2.0 changed the behavior how apps are deleted, showing a delete button above the app icon.
                let deleteButton = homeScreenIcons[appName].buttons["Delete"]
                XCTAssert(deleteButton.waitForExistence(timeout: 5.0))
                deleteButton.tap()
            } else { // iPhone / iPad / visionOS 1
                if !springboard.collectionViews.buttons["Remove App"].waitForExistence(timeout: 5) {
                    if springboard.state != .runningForeground {
                        // The long press did not work, let's launch the springboard again and then try long pressing the app icon again.
                        springboard.activate()
                        XCTAssert(springboard.wait(for: .runningForeground, timeout: 2.0))
                        XCTAssert(icon.isHittable)
                        icon.press(forDuration: 1.75)
                    }
                    if springboard.collectionViews.buttons["Options"].exists {
                        // We long-pressed the app icon, and the "Remove App" button isn't showing up, but an "Options" button is.
                        // Sometimes, for reasons probably not known to anyone, the home screen will put the "Remove App" button into
                        // an "Options" submenu, instead of placing it in the root of the menu.
                        // So we first need to navigate to that submenu, and then try again
                        springboard.collectionViews.buttons["Options"].tap()
                        XCTAssert(springboard.buttons["Remove App"].waitForExistence(timeout: 5))
                    }
                }
                guard springboard.buttons["Remove App"].waitForExistence(timeout: 2.0) else {
                    XCTFail("The context menu of \"\(appName)\" did not show a \"Remove App\" button.")
                    return
                }
                springboard.buttons["Remove App"].tap()
            }

            #if os(visionOS)
            // alerts are running in their own process on visionOS (lol). Took me literally 3 hours.
            let notifications = visionOSNotifications

            XCTAssert(notifications.staticTexts["Delete “\(appName)”?"].waitForExistence(timeout: 5.0))
            XCTAssert(notifications.buttons["Delete"].waitForExistence(timeout: 2.0))
            notifications.buttons["Delete"].tap() // currently no better way of hitting some "random" delete button.
            #else
            XCTAssert(springboard.alerts["Remove “\(appName)”?"].buttons["Delete App"].waitForExistence(timeout: 10.0))
            springboard.alerts["Remove “\(appName)”?"].buttons["Delete App"].tap()
            XCTAssert(springboard.alerts["Delete “\(appName)”?"].buttons["Delete"].waitForExistence(timeout: 10.0))
            springboard.alerts["Delete “\(appName)”?"].buttons["Delete"].tap()
            #endif

            // If the app had health data stored, deleting the app will show an alert, which we need to dismiss.
            // We also use this check to provide a 5 second timeout for the app to be deleted.
            let alertTitle = "There is data from “\(appName)” saved in Health"
            if springboard.alerts[alertTitle].waitForExistence(timeout: 5.0) {
                springboard.alerts[alertTitle].buttons["OK"].tap()
            }
            
            // Exit the while loop early without a `homeScreenIcons[appName].firstMatch.waitForExistence(timeout: 10.0)` call.
            // If the app takes longer to be deleted, this will give it some more time.
            // Only leads to a delay if we have to delete multiple apps with the same name; otherwise, it exits as soon as the app is removed or even immediately.
            if homeScreenIcons[appName].waitForNonExistence(timeout: 10.0) {
                break
            }
        }
    }

    /// Finds an icon with the given name that is currently on screen, paging through the home screen if needed.
    ///
    /// Several apps can share a name (most Spezi packages ship a "TestApp"), which can push an icon onto a later page.
    /// The home screen also remembers the last page shown, so the search starts from the first page when the page indicator is available.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    private static func findVisibleIcon(named name: String, in icons: XCUIElementQuery, on springboard: XCUIApplication) -> XCUIElement? {
        func visibleIcon() -> XCUIElement? {
            icons.matching(identifier: name).allElementsBoundByIndex.first { icon in
                // Only query `isHittable` for icons within the screen bounds, since it can record a failure for off-screen elements.
                let frame = icon.frame
                return !frame.isEmpty && springboard.frame.contains(CGPoint(x: frame.midX, y: frame.midY)) && icon.isHittable
            }
        }

        if let icon = visibleIcon() {
            return icon
        }

        #if os(iOS)
        let pages = homeScreenPages(of: springboard)
        // Return to the first page; swiping right on the first page would open the Today view instead.
        for _ in 0..<max((pages?.current ?? 1) - 1, 0) {
            springboard.swipeRight()
        }
        let maxSwipes = (pages?.total ?? 10) - 1
        #else
        let maxSwipes = 1
        #endif

        for swipe in 0...maxSwipes {
            if swipe > 0 {
                springboard.swipeLeft()
            }
            // Give the page transition a moment to settle before checking the icons on the new page.
            let predicate = NSPredicate { _, _ in visibleIcon() != nil }
            _ = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: nil)], timeout: 1.0)
            if let icon = visibleIcon() {
                return icon
            }
        }
        return nil
    }

    #if os(iOS)
    /// Reads the current page and the total number of pages from the home screen page indicator, e.g., "Page 2 of 3".
    private static func homeScreenPages(of springboard: XCUIApplication) -> (current: Int, total: Int)? {
        let indicator = springboard.pageIndicators.firstMatch
        guard indicator.exists, let value = indicator.value as? String else {
            return nil
        }
        let numbers = value.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        guard numbers.count == 2 else {
            return nil
        }
        return (numbers[0], numbers[1])
    }
    #endif
}
