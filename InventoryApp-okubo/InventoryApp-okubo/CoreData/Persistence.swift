//
//  Persistence.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/15.
//

import CoreData
import CloudKit

class PersistenceController {
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
    let container: NSPersistentCloudKitContainer
    // 初期化
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Persistent Store Description の取得に失敗")
        }
        // Persistent Historyのトラッキング有効
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // リモートの変更を検知
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        // iCloud Drive Documents のコードでiCloudが使用可能か検出する。アカウントに変更があるとアプリが再起動される。
        if FileManager.default.ubiquityIdentityToken == nil {
            print("iCloud使用不可")
            // CloudKitとの同期を切る
            description.cloudKitContainerOptions = nil
        } else {
            print("iCloud使用可能")
//            description.cloudKitContainerOptions = .init(containerIdentifier: "iCloud.InventoryApp-okubo")
        }
        // データが重複しないよう外部変更はメモリ内を置き換える
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        // クラウドからの変更を自動取得して適用する
        container.viewContext.automaticallyMergesChangesFromParent = true
        // 永続ストアをロード
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        do {
            // Contextを現在のPersistentStoreにpinする
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print("viewContextを現世代に固定することに失敗しました。")
        }
    }
}
