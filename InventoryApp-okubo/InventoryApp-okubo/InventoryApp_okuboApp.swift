//
//  InventoryApp_okuboApp.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/04.
//

import SwiftUI

@main
struct InventoryApp_okuboApp: App {
    // NSPersistentContainerの初期化
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
