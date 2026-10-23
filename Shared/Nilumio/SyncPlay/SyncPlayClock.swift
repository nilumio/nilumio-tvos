//
// nilumio – Uhrabgleich mit dem Jellyfin-Server für SyncPlay.
// Steht wie das übrige Projekt unter der Mozilla Public License 2.0.
// Reine Logik ohne Abhängigkeiten, getestet in Tests/Nilumio/SyncPlayClockTests.swift.
//
// Copyright (c) 2026 Niklas Held
//

import Foundation

/// NTP-artiger Abgleich: Von den letzten 8 Messungen gilt die mit der kürzesten Laufzeit.
struct SyncPlayClock {

    /// Serverzeit minus lokale Zeit (Sekunden).
    private(set) var offset: TimeInterval = 0
    /// Laufzeit der gültigen Messung ohne Bearbeitungszeit auf dem Server (Sekunden).
    private(set) var roundTrip: TimeInterval = 0
    private(set) var samples: [(roundTrip: TimeInterval, offset: TimeInterval)] = []

    /// Neue Messung: lokal gesendet/empfangen, auf dem Server empfangen/gesendet (`/GetUtcTime`).
    mutating func add(sent: Date, serverReceived: Date, serverSent: Date, received: Date) {
        let roundTrip = received.timeIntervalSince(sent) - serverSent.timeIntervalSince(serverReceived)
        let offset = (serverReceived.timeIntervalSince(sent) + serverSent.timeIntervalSince(received)) / 2
        samples = Array((samples + [(roundTrip, offset)]).suffix(8))
        (self.roundTrip, self.offset) = samples.min { $0.roundTrip < $1.roundTrip }!
    }

    func serverTime(at localTime: Date = Date()) -> Date {
        localTime.addingTimeInterval(offset)
    }

    func localTime(at serverTime: Date) -> Date {
        serverTime.addingTimeInterval(-offset)
    }
}
