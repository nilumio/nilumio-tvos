//
// nilumio – Tests für SyncPlayClock (reine Logik, ohne Xcode-Testtarget).
// Ausführen im Repo-Wurzelverzeichnis:
//   swiftc -parse-as-library -o /tmp/syncplay-clock-tests \
//     Shared/Nilumio/SyncPlay/SyncPlayClock.swift Tests/Nilumio/SyncPlayClockTests.swift && /tmp/syncplay-clock-tests
//
// Copyright (c) 2026 Niklas Held
//

import Foundation

@main
enum SyncPlayClockTests {

    static func main() {
        let t0 = Date(timeIntervalSince1970: 1000)

        // Server geht 5 s vor, Hin- und Rückweg je 0,1 s, 0,2 s Bearbeitung auf dem Server.
        var clock = SyncPlayClock()
        clock.add(sent: t0, serverReceived: t0 + 5.1, serverSent: t0 + 5.3, received: t0 + 0.4)
        check(clock.offset, 5, "Versatz")
        check(clock.roundTrip, 0.2, "Laufzeit ohne Bearbeitung")
        check(clock.serverNow.timeIntervalSinceNow, 5, "Serverzeit", tolerance: 0.01)

        // Eine langsamere Messung mit anderem Versatz ändert nichts, eine schnellere gilt sofort.
        clock.add(sent: t0, serverReceived: t0 + 6, serverSent: t0 + 6, received: t0 + 1)
        check(clock.offset, 5, "langsamere Messung ignoriert")
        clock.add(sent: t0, serverReceived: t0 + 4.05, serverSent: t0 + 4.05, received: t0 + 0.1)
        check(clock.offset, 4, "schnellere Messung gilt")

        // Nur die letzten 8 Messungen zählen: Acht langsamere verdrängen die schnellste.
        for _ in 0 ..< 8 {
            clock.add(sent: t0, serverReceived: t0 + 3.5, serverSent: t0 + 3.5, received: t0 + 1)
        }
        check(clock.samples.count, 8, "höchstens 8 Messungen")
        check(clock.offset, 3, "älteste Messung fällt heraus")

        // Neustart behält den Versatz bis zur ersten neuen Messung.
        check(SyncPlayClock(offset: clock.offset).offset, 3, "Neustart behält Versatz")

        print(failures == 0 ? "SyncPlayClockTests: alle Prüfungen bestanden" : "SyncPlayClockTests: \(failures) Fehler")
        exit(failures == 0 ? 0 : 1)
    }

    nonisolated(unsafe) static var failures = 0

    static func check(_ actual: Double, _ expected: Double, _ name: String, tolerance: Double = 1e-6) {
        if abs(actual - expected) > tolerance {
            failures += 1
            print("FEHLER \(name): \(actual) statt \(expected)")
        }
    }

    static func check(_ actual: Int, _ expected: Int, _ name: String) {
        check(Double(actual), Double(expected), name)
    }
}
