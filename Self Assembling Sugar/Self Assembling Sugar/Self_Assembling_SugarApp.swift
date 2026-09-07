//
//  Self_Assembling_SugarApp.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/6/26.
//

import SwiftUI
import CoreData

@main
struct Self_Assembling_SugarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
