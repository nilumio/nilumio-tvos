import XCTest

// App Store screenshots (1920×1080). Expects nilumio to be signed in already
// (SignIn.testQuickConnect does the one-time Quick Connect sign-in).
final class StoreScreenshots: XCTestCase {

    let app = XCUIApplication(bundleIdentifier: "com.held0.nilumio")
    let remote = XCUIRemote.shared
    lazy var dir = ProcessInfo.processInfo.environment["SHOT_DIR"] ?? NSTemporaryDirectory()

    func shot(_ name: String, debug: Bool = true) throws {
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
        if debug { try app.debugDescription.write(toFile: "\(dir)/\(name).txt", atomically: true, encoding: .utf8) }
    }

    func press(_ button: XCUIRemote.Button, _ times: Int = 1, wait: UInt32 = 1) {
        for _ in 0 ..< times {
            remote.press(button)
            sleep(wait)
        }
    }

    /// The tvOS tab sidebar keeps its entries in the tree with a zero frame while collapsed.
    var sidebarOpen: Bool {
        app.buttons["Startseite"].firstMatch.frame.width > 0
    }

    /// Opens the side menu (left edge; one step back first if needed) and selects `label`.
    func openMenu(_ label: String) {
        for attempt in 0 ..< 3 where !sidebarOpen {
            if attempt > 0 {
                press(.menu, wait: 3)
                if app.state != .runningForeground { app.activate(); sleep(3) }
            }
            for _ in 0 ..< 6 where !sidebarOpen {
                press(.left, wait: 1)
            }
        }
        // hasFocus is not reported for sidebar entries, so count steps from the top
        let order = ["Startseite", "TV Serien", "Filme", "Suche", "Medien", "SyncPlay", "Einstellungen"]
        for _ in 0 ..< 8 {
            remote.press(.up)
            usleep(300_000)
        }
        sleep(1)
        press(.down, order.firstIndex(of: label) ?? 0, wait: 1)
        press(.select, wait: 5)
    }

    func testStore() throws {
        app.terminate()
        app.activate()
        XCTAssertTrue(app.buttons["Startseite"].waitForExistence(timeout: 30))
        sleep(8)
        try shot("01-home")

        openMenu("Filme")
        try shot("03-movies")

        openMenu("TV Serien")
        press(.select, wait: 5)
        try shot("04-series")

        openMenu("Startseite")
        sleep(3)
        for _ in 0 ..< 6 where !sidebarOpen {
            press(.left, wait: 1)
        }
        sleep(1)
        try shot("05-menu")

        press(.right, wait: 2)
        press(.right, wait: 4)
        press(.select, wait: 5)
        try shot("02-movie")

        press(.select, wait: 10)
        press(.select, wait: 3)
        try shot("06-player")
    }
}
