//
// nilumio – Seite „Gemeinsam schauen“ (Jellyfin SyncPlay) und ihr Menüpunkt.
// Steht wie das übrige Projekt unter der Mozilla Public License 2.0.
//
// Copyright (c) 2026 Niklas Held
//

import JellyfinAPI
import SwiftUI

private func t(_ de: String, _ en: String) -> String {
    Nilumio.istDeutsch ? de : en
}

extension TabItem {

    static var syncPlay: TabItem {
        _ = SyncPlayManager.shared // Gruppen-Nachrichten ab App-Start empfangen
        return TabItem(id: "nilumio-syncplay", title: t("Gemeinsam schauen", "Watch together"), systemImage: "person.2") {
            SyncPlayView()
        }
    }
}

struct SyncPlayView: View {

    @ObservedObject
    private var syncPlay = SyncPlayManager.shared

    var body: some View {
        List {
            if let group = syncPlay.group {
                Section(t("Deine Gruppe", "Your group")) {
                    LabeledContent(group.groupName ?? "–", value: (group.participants ?? []).joined(separator: ", "))
                    Text(t(
                        "Starte etwas zum Ansehen – alle in der Gruppe sehen es gleichzeitig. Pause und Spulen gelten für alle.",
                        "Start something to watch – everyone in the group sees it at the same time. Pausing and seeking apply to everyone."
                    ))
                    .foregroundStyle(.secondary)
                    Button(t("Gruppe verlassen", "Leave group"), role: .destructive) { syncPlay.verlassen() }
                }
            } else {
                Section {
                    Button {
                        Task { await syncPlay.erstellen() }
                    } label: {
                        Label(t("Neue Gruppe", "New group"), systemImage: "plus")
                    }
                }
                Section(t("Gruppen auf dem Server", "Groups on the server")) {
                    if syncPlay.groups.isEmpty {
                        Text(t("Keine Gruppen. Lege eine an oder starte eine in einer anderen Jellyfin-App.",
                               "No groups. Create one or start one in another Jellyfin app."))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(syncPlay.groups, id: \.groupID) { group in
                        Button {
                            syncPlay.beitreten(group)
                        } label: {
                            LabeledContent(group.groupName ?? "–", value: (group.participants ?? []).joined(separator: ", "))
                        }
                    }
                }
            }
            if let fehler = syncPlay.fehler {
                Text(fehler).foregroundStyle(.red)
            }
        }
        .navigationTitle(t("Gemeinsam schauen", "Watch together"))
        .task { await syncPlay.laden() }
        .onChange(of: syncPlay.group?.groupID) { Task { await syncPlay.laden() } }
    }
}
