//
//  Persistence.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/15.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    // プレビューで扱うデータ
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // プレビュー用のフォルダデータ
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.name = "買い物"
        newFolder.icon = Icon.house.rawValue
        newFolder.isStock = true
        // プレビュー用の商品データ
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = "テスト"
        newItem.image = nil
        newItem.numberOfItems = 1
        newItem.status = ItemStatus.unOpened.rawValue
        newItem.isHurry = false
        newItem.deadLine = nil
        newItem.notificationDate = nil
        newItem.registrationDate = Date()
        newItem.folder = newFolder
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    // 永続化コンテナ
    let container: NSPersistentContainer
    // 初期化
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
