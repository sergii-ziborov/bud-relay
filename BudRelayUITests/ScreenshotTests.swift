import XCTest

/// Walks every screen and keeps PNG attachments; the repo's docs/screenshots are exported from the xcresult.
@MainActor
final class ScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testWelcomeAndFirstLevel() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "show-welcome"]
        app.launch()
        XCTAssertTrue(app.buttons["story-next"].waitForExistence(timeout: 8))
        sleep(1)
        shoot("00-welcome")
        for _ in 0..<6 where app.buttons["story-next"].exists {
            app.buttons["story-next"].tap()
            usleep(300_000)
        }
        XCTAssertTrue(app.buttons["howto-next"].waitForExistence(timeout: 8))
        for _ in 0..<3 {
            app.buttons["howto-next"].tap()
            usleep(300_000)
        }
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 8))
        shoot("01-home-fresh")
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["card-0"].waitForExistence(timeout: 8))
        var turn = 0
        while turn < 10, !app.staticTexts["result-title"].exists {
            turn += 1
            if !playHintedTurn(app, shotName: turn >= 2 && turn <= 5 ? "03-relay-\(turn)" : nil) { break }
        }
        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 12))
        sleep(1)
        shoot("05-result")
        if app.buttons["next-level-button"].exists {
            app.buttons["next-level-button"].tap()
            XCTAssertTrue(app.buttons["pause-button"].waitForExistence(timeout: 8))
        }
    }

    func testHubScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "demo-progress"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 8))
        sleep(1)
        shoot("01-home")

        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["card-0"].waitForExistence(timeout: 8))
        sleep(1)
        shoot("02-play")
        _ = playHintedTurn(app, shotName: nil)
        _ = playHintedTurn(app, shotName: nil)
        app.buttons["pause-button"].tap()
        XCTAssertTrue(app.buttons["resume-button"].waitForExistence(timeout: 5))
        shoot("04-pause")
        app.buttons["Quit"].tap()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 8))

        app.buttons["map-button"].tap()
        sleep(1)
        shoot("06-map")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 8))

        for (id, name) in [("nav-garden", "07-garden"), ("nav-greenhouse", "08-greenhouse"), ("nav-market", "09-market"), ("nav-daily", "10-daily")] {
            let button = app.buttons[id]
            XCTAssertTrue(button.waitForExistence(timeout: 8), id)
            button.tap()
            sleep(1)
            shoot(name)
            app.buttons["back-button"].tap()
            XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 8))
        }
        XCTAssertTrue(app.buttons["howto-button"].waitForExistence(timeout: 8))
        app.buttons["howto-button"].tap()
        sleep(1)
        shoot("11-howto")
        app.buttons["howto-next"].tap()
        sleep(1)
        shoot("12-howto-relay")
    }

    func testExpandedCollectionTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "demo-progress"]
        app.launch()
        XCTAssertTrue(app.buttons["nav-greenhouse"].waitForExistence(timeout: 8))
        app.buttons["nav-greenhouse"].tap()

        let trees = app.buttons["greenhouse-tab-trees"]
        XCTAssertTrue(trees.waitForExistence(timeout: 8))
        trees.tap()
        sleep(1)
        shoot("13-tree-arboretum")
        XCTAssertTrue(app.buttons["tree-collection-apple"].exists)

        let journal = app.buttons["greenhouse-tab-journal"]
        XCTAssertTrue(journal.exists)
        journal.tap()
        sleep(1)
        shoot("14-lore-journal")
        XCTAssertTrue(app.staticTexts["Green Neighbors Journal"].exists)
    }

    func testGardenExpansionAndPlacementTargets() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "demo-progress"]
        app.launch()
        XCTAssertTrue(app.buttons["nav-garden"].waitForExistence(timeout: 8))
        app.buttons["nav-garden"].tap()
        XCTAssertTrue(app.buttons["garden-goals"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["garden-zoom-in"].exists)
        XCTAssertTrue(app.buttons["garden-activity-tidyLeaves"].exists)
        sleep(1)
        shoot("15-garden-estate")

        let pathStone = app.buttons["inventory-pathStone"]
        XCTAssertTrue(pathStone.exists)
        pathStone.tap()
        sleep(1)
        shoot("16-garden-path-targets")

        let pathTarget = app.buttons["garden-5-0"]
        XCTAssertTrue(pathTarget.exists)
        pathTarget.tap()
        expectation(for: NSPredicate(format: "label == 'Path Stone'"), evaluatedWith: pathTarget)
        waitForExpectations(timeout: 3)

        let courtyard = app.buttons["garden-region-courtyard"]
        XCTAssertTrue(courtyard.exists)
        courtyard.tap()
        XCTAssertTrue(app.buttons["garden-tend-region"].waitForExistence(timeout: 3))
        shoot("17-garden-region-highlight")

        let bench = app.buttons["garden-5-3"]
        XCTAssertTrue(bench.exists)
        bench.tap()
        XCTAssertTrue(app.buttons["garden-collect-item"].waitForExistence(timeout: 3))
        shoot("18-garden-object-action")
        app.buttons["garden-collect-item"].tap()
    }

    /// Uses a hint when one is left, otherwise drops the first card on the first empty plot.
    /// Returns false when nothing could be played.
    @discardableResult
    private func playHintedTurn(_ app: XCUIApplication, shotName: String?) -> Bool {
        let card = app.buttons["card-0"]
        guard card.waitForExistence(timeout: 4), card.isEnabled else { return false }
        var target: XCUIElement?
        let hint = app.buttons["hint-button"]
        if hint.exists, hint.isEnabled {
            hint.tap()
            usleep(200_000)
            let hinted = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'plot-' AND value == 'hinted'")).firstMatch
            if hinted.exists { target = hinted }
        }
        if target == nil {
            card.tap()
            for row in 0..<5 {
                for col in 0..<5 {
                    let plot = app.buttons["plot-\(row)-\(col)"]
                    if plot.exists, plot.isEnabled, plot.label == "Empty plot" {
                        target = plot
                        break
                    }
                }
                if target != nil { break }
            }
        }
        guard let target else {
            app.buttons["tend-button"].tap()
            usleep(1_800_000)
            return true
        }
        target.tap()
        if let shotName {
            usleep(520_000)
            shoot(shotName)
        }
        usleep(2_400_000)
        return true
    }

    private func shoot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
