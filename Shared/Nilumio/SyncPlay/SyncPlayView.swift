//
// nilumio – Seite SyncPlay (Jellyfin SyncPlay) und ihr Menüpunkt.
// Steht wie das übrige Projekt unter der Mozilla Public License 2.0.
//
// Copyright (c) 2026 Niklas Held
//

import JellyfinAPI
import SwiftUI

extension TabItem {

    static var syncPlay: TabItem {
        _ = SyncPlayManager.shared // Gruppen-Nachrichten ab App-Start empfangen
        return TabItem(id: "nilumio-syncplay", title: "SyncPlay", systemImage: "person.2") {
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
                Section(Nilumio.text(de: "Deine Gruppe", en: "Your group")) {
                    groupRow(group)
                    Text(Nilumio.text(
                        de: "Starte etwas zum Ansehen – alle in der Gruppe sehen es gleichzeitig. Pause und Spulen gelten für alle.",
                        en: "Start something to watch – everyone in the group sees it at the same time. Pausing and seeking apply to everyone."
                    ))
                    .foregroundStyle(.secondary)
                    Button(Nilumio.text(de: "Gruppe verlassen", en: "Leave group"), role: .destructive) { syncPlay.leave() }
                }
            } else {
                Section {
                    Button {
                        Task { await syncPlay.createGroup() }
                    } label: {
                        Label(Nilumio.text(de: "Neue Gruppe", en: "New group"), systemImage: "plus")
                    }
                }
                Section(Nilumio.text(de: "Gruppen auf dem Server", en: "Groups on the server")) {
                    if syncPlay.groups.isEmpty {
                        Text(Nilumio.text(
                            de: "Keine Gruppen. Lege eine an oder starte eine in einer anderen Jellyfin-App.",
                            en: "No groups. Create one or start one in another Jellyfin app."
                        ))
                        .foregroundStyle(.secondary)
                    }
                    ForEach(syncPlay.groups, id: \.groupID) { group in
                        Button {
                            syncPlay.join(group)
                        } label: {
                            groupRow(group)
                        }
                    }
                }
            }
            if let errorMessage = syncPlay.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("SyncPlay")
        .task { await syncPlay.loadGroups() }
        .onChange(of: syncPlay.group?.groupID) { Task { await syncPlay.loadGroups() } }
    }

    private func groupRow(_ group: GroupInfoDto) -> some View {
        LabeledContent(group.groupName ?? "–", value: (group.participants ?? []).joined(separator: ", "))
    }
}
