//
//  CraftJournalApp.swift
//  CraftJournal
//
//  Created by iMac15 on 9/30/26.
//

import SwiftUI

@main
struct CraftJournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
