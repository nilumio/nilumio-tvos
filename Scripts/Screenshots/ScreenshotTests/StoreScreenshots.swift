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
    /// Label of the first sidebar entry; SHOT_LANG=en for an English simulator.
    lazy var homeLabel = ProcessInfo.processInfo.environment["SHOT_LANG"] == "en" ? "Home" : "Startseite"

    var sidebarOpen: Bool {
        app.buttons[homeLabel].firstMatch.frame.width > 0
    }

    enum Menu: Int { case home, series, movies, search, media, syncPlay, settings }

    /// Opens the side menu (left edge; one step back first if needed) and selects `label`.
    func openMenu(_ entry: Menu) {
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
        for _ in 0 ..< 8 {
            remote.press(.up)
            usleep(300_000)
        }
        sleep(1)
        press(.down, entry.rawValue, wait: 1)
        press(.select, wait: 5)
    }

    let env = ProcessInfo.processInfo.environment

    /// Moves right until the button labelled `label` has focus.
    func focusRight(_ label: String) {
        let focused = app.buttons.matching(NSPredicate(format: "hasFocus == true")).firstMatch
        for _ in 0 ..< 8 where focused.label != label {
            press(.right, wait: 2)
        }
    }

    func testStore() throws {
        app.terminate()
        app.activate()
        XCTAssertTrue(app.buttons[homeLabel].waitForExistence(timeout: 30))
        sleep(8)
        try shot("01-home")

        openMenu(.movies)
        try shot("03-movies")

        openMenu(.series)
        try shot("04-series")
        // the series with three seasons
        focusRight(env["SHOT_SHOW"] ?? "Die Hafenkommissarin")
        press(.select, wait: 5)
        try shot("05-show")
        press(.down, 2, wait: 2)
        try shot("05b-show-seasons")
        press(.down, wait: 2)
        try shot("05c-show-episodes")

        openMenu(.syncPlay)
        sleep(2)
        press(.right, wait: 2)
        try shot("06-syncplay")
        press(.select, wait: 4)
        try shot("06b-syncplay-group")
        press(.select, wait: 3) // leave the group again

        openMenu(.home)
        sleep(3)
        for _ in 0 ..< 6 where !sidebarOpen {
            press(.left, wait: 1)
        }
        sleep(1)
        try shot("08-menu")

        // back into the first row, then right until the film has focus
        press(.right, wait: 4)
        focusRight(env["SHOT_MOVIE"] ?? "Nachtschicht")
        press(.select, wait: 5)
        try shot("02-movie")

        press(.select, wait: 10)
        press(.select, wait: 3)
        try shot("07-player-movie")
    }

    /// Opens the series with three seasons (its play button resumes an episode).
    func openShow() {
        app.terminate()
        app.activate()
        XCTAssertTrue(app.buttons[homeLabel].waitForExistence(timeout: 30))
        sleep(5)
        openMenu(.series)
        focusRight(env["SHOT_SHOW"] ?? "Die Hafenkommissarin")
        press(.select, wait: 5)
    }

    func testShowPlayer() throws {
        openShow()
        press(.select, wait: 10)
        press(.select, wait: 3)
        try shot("07-player")
    }

    func testShowSeasons() throws {
        openShow()
        // play button → favourites row → season tabs → first episode row
        press(.down, wait: 2)
        press(.down, wait: 2)
        try shot("05-show-1")
        remote.press(.down)
        usleep(500_000)
        try shot("05-show-2")
        press(.right, wait: 2)
        try shot("05-show-3")
    }
}
