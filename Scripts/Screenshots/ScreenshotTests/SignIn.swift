import XCTest

// One-time sign-in via Quick Connect: writes the code to $SHOT_DIR/code.txt and waits up to
// three minutes until it is authorised (e.g. by an admin via POST /QuickConnect/Authorize).
final class SignIn: XCTestCase {

    let app = XCUIApplication(bundleIdentifier: "com.held0.nilumio")
    let remote = XCUIRemote.shared
    let env = ProcessInfo.processInfo.environment
    lazy var dir = env["SHOT_DIR"] ?? NSTemporaryDirectory()
    var step = 0

    func dump(_ name: String) throws {
        step += 1
        let base = dir + "/\(step)-\(name)"
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: base + ".png"))
        try app.debugDescription.write(toFile: base + ".txt", atomically: true, encoding: .utf8)
    }

    func testQuickConnect() throws {
        app.terminate()
        app.activate()
        let add = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Benutzer hinz'")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 20))
        let qc = app.buttons["Schnellverbindung"].firstMatch
        for _ in 0 ..< 10 where !qc.exists {
            sleep(3)
            remote.press(.select)
        }
        sleep(2)
        try dump("signin")
        for _ in 0 ..< 6 where !qc.hasFocus {
            remote.press(.down)
            usleep(600_000)
        }
        remote.press(.select)
        sleep(4)
        try dump("quickconnect")
        let code = app.staticTexts.allElementsBoundByIndex.map(\.label).first { $0.count == 6 && Int($0) != nil } ?? ""
        try code.write(toFile: dir + "/code.txt", atomically: true, encoding: .utf8)
        for _ in 0 ..< 60 where app.staticTexts[code].exists {
            sleep(3)
        }
        sleep(5)
        try dump("after-signin")
    }
}
