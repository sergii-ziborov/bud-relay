import XCTest

final class BudRelayUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndPlayALevel() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        saveShot("home")
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["card-0"].waitForExistence(timeout: 5))
        saveShot("play")

        for _ in 0..<6 {
            let card = app.buttons["card-0"]
            guard card.waitForExistence(timeout: 3) else { break }
            card.tap()
            var placed = false
            for row in 0..<5 {
                for col in 0..<5 {
                    let plot = app.buttons["plot-\(row)-\(col)"]
                    if plot.exists && plot.isEnabled {
                        plot.tap()
                        placed = true
                        break
                    }
                }
                if placed { break }
            }
            if app.staticTexts["result-title"].exists { break }
            sleep(2)
        }
        saveShot("play-later")
    }

    func testVisitEveryScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        for (id, name) in [("nav-garden", "garden"), ("nav-greenhouse", "greenhouse"), ("nav-market", "market"), ("nav-daily", "daily")] {
            let button = app.buttons[id]
            XCTAssertTrue(button.waitForExistence(timeout: 5), id)
            button.tap()
            sleep(1)
            saveShot(name)
        }
        app.buttons["nav-home"].tap()
        XCTAssertTrue(app.buttons["map-button"].waitForExistence(timeout: 5))
        app.buttons["map-button"].tap()
        sleep(1)
        saveShot("map")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
