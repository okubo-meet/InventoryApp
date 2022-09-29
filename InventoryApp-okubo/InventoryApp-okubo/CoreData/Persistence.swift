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
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // TODO: - iCloudの同期を切っても、それまで登録していたデータはローカルに残したい
//        description.cloudKitContainerOptions = nil
        // データが重複しないよう外部変更はメモリ内を置き換える
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        // クラウドからの変更を自動取得して適用する
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            // Contextを現在のPersistentStoreにpinする
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print("viewContextを現世代に固定することに失敗しました。")
        }
    }
    // MARK: - CKQuerySubscriptionがうまくいきそうなので不要に
    // リモートからの新規トランザクションを監視し、必要に応じて Context の更新などを行う
    //        NotificationCenter.default.addObserver(self,
    //                                               selector: #selector(storeRemoteChange(_:)),
    //                                               name: .NSPersistentStoreRemoteChange,
    //                                               object: container.persistentStoreCoordinator)
    // リモートの変更を受け取った時の処理
//    @objc func storeRemoteChange(_ notification: Notification) {
//        precondition(notification.name == NSNotification.Name.NSPersistentStoreRemoteChange)
//        //        print("変更通知：　\(String(describing: notification.userInfo))")
//        //        let storeURL = notification.userInfo?[NSPersistentStoreURLKey]!
//        let token = notification.userInfo?[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken
//        print("リモート変更通知: \(String(describing: token))")
//        // データ履歴取得
//        let historyRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: token)
//        let result = try? container.newBackgroundContext().execute(historyRequest) as? NSPersistentHistoryResult
//        //        print("変更履歴：　\(String(describing: result))")
//        if let transactions = result?.result as? [NSPersistentHistoryTransaction] {
//            for transaction in transactions {
//                print("トランザクション：\(String(describing: transaction))")
//                guard let userInfo = transaction.objectIDNotification().userInfo else { return }
//                print("ユーザーインフォ：\(userInfo)")
//                // データ履歴のキー
//                let insertedKey = "inserted_objectIDs" // 追加
//                let updatedKey = "updated_objectIDs" // 更新
//                let deletedKey = "deleted_objectIDs" // 削除
//                // NSManagedObjectIDの集合に変換
//                if let updatedID = userInfo[deletedKey] as? Set<NSManagedObjectID> {
//                    print("ID: \(updatedID)")
//                    print(type(of: updatedID))
//                    // NSManagedObjectIDの配列に変換
//                    let idArray = Array(updatedID)
//                    // NSPersistentCloudKitContainerからCKRecordsを取得
//                    let record = container.record(for: idArray[0])
//                    print("レコード： \(String(describing: record))")
//                    // CKRecordから値を取りたいキー
//                    let entityKey = "CD_entityName" // エンティティ名
//                    let nameKey = "CD_name" // 商品名
//                    let uuidKey = "CD_id" // UUID
//                    let notificationKey = "CD_notificationDate" // 通知日程
//                    let folderKey = "CD_folder" // フォルダ
//                    if let entity = record?[entityKey] as? String {
//                        if entity == "Item" {
//                            let name = record?[nameKey] as? String
//                            print("レコード： \(String(describing: name))")
//                        }
//                    }
//                }
//            }
//        }
//    }
}
