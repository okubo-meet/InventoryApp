//
//  AppDelegate.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/11/16.
//

import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // MARK: - プロパティ
    // サブスクリプション作成済みかを表すBool（UserDefaultsで保存）
    private let didCreateQuerySubscription = UserDefaults.standard.bool(forKey: "didCreateQuerySubscription")
    // ローカル通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // MARK: - メソッド
    // 起動時
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("アプリ起動")
        // ローカル通知の許可
        notificationManager.requestPermission()
        print("ユーザーデフォルト: \(didCreateQuerySubscription)")
        // ユーザーデフォルトの値がfalseの時の処理（サブスクリプション作成）
        if !didCreateQuerySubscription {
            Task {
                // データベース
                let containerIdentifier = "iCloud.InventoryApp-okubo"
                let ckContainer = CKContainer(identifier: containerIdentifier)
                let cloudDatabase = ckContainer.privateCloudDatabase
                // レコードゾーン
                let recordZoneName = "com.apple.coredata.cloudkit.zone"
                let recordZone = CKRecordZone(zoneName: recordZoneName)
                // データベースにあるレコードゾーンを全て取得
                let zones = try await cloudDatabase.allRecordZones()
                for zone in zones {
                    // デフォルトゾーンだけを削除する
                    if zone.zoneID == recordZone.zoneID {
                        print("保持するゾーン：　\(zone)")
                    } else {
                        try await cloudDatabase.deleteRecordZone(withID: zone.zoneID)
                        print("不要なレコードゾーン削除：　\(zone)")
                    }
                }
                // cloud変更のサブスクリプション作成
                let subscriptionID = "com.apple.coredata.cloudkit.private.subscription"
                let ckSubscription = CKQuerySubscription(recordType: "CD_Item",
                                                         predicate: NSPredicate(value: true),
                                                         subscriptionID: subscriptionID,
                                                         options: [.firesOnRecordCreation,
                                                                   .firesOnRecordUpdate,
                                                                   .firesOnRecordDeletion])
                ckSubscription.zoneID = recordZone.zoneID
                // 通知設定
                let notification = CKSubscription.NotificationInfo()
                notification.shouldSendContentAvailable = true
                // 通知されるデータを設定
                notification.desiredKeys = ["CD_name", "CD_id", "CD_notificationDate"]
                ckSubscription.notificationInfo = notification
                // iCloudアカウントのチェック
                CKContainer.default().accountStatus { status, error in
                    if let error = error {
                        print("iCloudアカウントの状態確認に失敗: \(error.localizedDescription)")
                    }
                    // iCloudアカウントが利用可能な場合にサブスクリプションを作成する
                    if status == .available {
                        // データベースにサブスクリプションを登録
                        cloudDatabase.save(ckSubscription) { subscription, error in
                            if let error = error {
                                print("サブスクリプション失敗： \(error.localizedDescription)")
                            } else {
                                print("サブスクリプション開始： \(String(describing: subscription))")
                                // ユーザーデフォルト更新
                                UserDefaults.standard.set(true, forKey: "didCreateQuerySubscription")
                            }
                        }
                    }
                }
            }// Task
        } else {
            print("サブスクリプション作成済み")
        }
        return true
    }
    // リモート通知を受け取った時の処理
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // ユーザーインフォからデータを取得する
        if let dictionary = userInfo as? [String: NSObject],
           let notification = CKNotification(fromRemoteNotificationDictionary: dictionary),
           let querynotification = notification as? CKQueryNotification {
            // querynotification.queryNotificationReasonが作成・更新・削除を表す
            let reason = querynotification.queryNotificationReason
            print("変更：\(reason), リモート通知：\(String(describing: querynotification.recordFields))")
            // 取得したデータ
            guard let recordFields = querynotification.recordFields else { return }
            // 識別IDを文字列で取得
            if let id = recordFields["CD_id"] as? String {
                print("id: \(String(describing: id))")
                // クラウドの変更を削除かそれ以外かで分岐
                if reason == .recordDeleted {
                    // 通知を削除する
                    notificationManager.removeNotification(identifier: id)
                } else {
                    // 通知日程が設定されているかで分岐
                    if let notificationDate = recordFields["CD_notificationDate"] as? NSNumber {
                        print("通知：\(String(describing: notificationDate))")
                        let date = Date(timeIntervalSinceReferenceDate: notificationDate.doubleValue)
                        print("日付：\(String(describing: date))")
                        // 商品名
                        let name = recordFields["CD_name"] as? String
                        print("商品名：\(String(describing: name))")
                        // 通知を更新する
                        notificationManager.makeNotification(name: name!,
                                                             notificationDate: date,
                                                             identifier: id)
                    } else {
                        // 通知を削除する
                        notificationManager.removeNotification(identifier: id)
                    }
                }
            }
            completionHandler(.newData)
        } else {
            print("データなし")
            completionHandler(.noData)
        }
    }
}
