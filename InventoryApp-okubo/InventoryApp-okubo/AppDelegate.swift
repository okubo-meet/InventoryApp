//
//  AppDelegate.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/11/16.
//

import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // 起動時
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("アプリ起動")
        // ローカル通知の許可
        NotificationManager().requestPermission()
        // データベース
        let containerIdentifier = "iCloud.InventoryApp-okubo"
        let ckContainer = CKContainer(identifier: containerIdentifier)
        let cloudDatabase = ckContainer.privateCloudDatabase
        // cloud変更のサブスクリプション作成
        let subscriptionID = "com.apple.coredata.cloudkit.private.subscription"
        let ckSubscription = CKQuerySubscription(recordType: "CD_Item",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: subscriptionID,
                                               options: [.firesOnRecordCreation,
                                                         .firesOnRecordUpdate,
                                                         .firesOnRecordDeletion])
        let recordZoneName = "com.apple.coredata.cloudkit.zone"
        let recordZone = CKRecordZone(zoneName: recordZoneName)
        ckSubscription.zoneID = recordZone.zoneID
        // 通知設定
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        // 通知されるデータを設定
        notification.desiredKeys = ["CD_name", "CD_id", "CD_notificationDate"]
        ckSubscription.notificationInfo = notification
        // TODO: - 一度iCloudの同期を切って戻してもサブスクリプションがエラーになり続けて機能しなくなる不具合
        // データベースにサブスクリプションを登録
        cloudDatabase.save(ckSubscription) { subscription, error in
            if let error = error {
                print("サブスクリプション失敗： \(error.localizedDescription)")
            } else {
                print("サブスクリプション開始： \(String(describing: subscription))")
            }
        }
        return true
    }
    // リモート通知を受け取った時の処理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // このユーザーインフォからデータが取れるか調査
        if let dictionary = userInfo as? [String: NSObject],
           let notification = CKNotification(fromRemoteNotificationDictionary: dictionary),
           let querynotification = notification as? CKQueryNotification {
            // querynotification.queryNotificationReasonが作成・更新・削除を表す
            let reason = querynotification.queryNotificationReason
            print("変更：\(reason)")
            print("リモート通知：\(String(describing: querynotification.recordFields))")
            // 取得したデータ
            guard let recordFields = querynotification.recordFields else { return }
            // 商品名
            let name = recordFields["CD_name"] as? String
            print("商品名：\(String(describing: name))")
            // 識別ID
            let id = recordFields["CD_id"] as? String
            print("id: \(String(describing: id))")
            // 通知日程
            if let notificationDate = recordFields["CD_notificationDate"] as? NSNumber {
                print("通知：\(String(describing: notificationDate)), \(String(describing: type(of: notificationDate)))")
                let date = Date(timeIntervalSinceReferenceDate: notificationDate.doubleValue)
                print("日付：\(String(describing: date))")// TimeZoneを指定する必要あり
            }
            // TODO: - クラウドからの変更を受け取ったとき、通知も更新したい
            completionHandler(.newData)
        } else {
            print("データなし")
            completionHandler(.noData)
        }
    }
}
