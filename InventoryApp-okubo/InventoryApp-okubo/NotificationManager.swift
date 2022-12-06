//
//  NotificationManager.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/08/14.
//

import Foundation
import UserNotifications
import SwiftUI

// 通知を扱うクラス
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // MARK: - プロパティ
    // アプリの通知センター
    private let notificationCenter = UNUserNotificationCenter.current()
    // MARK: - メソッド
    // フォアグラウンド通知デリゲートメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    /// 通知権限の状態を取得してその後の処理を呼び出す関数
    func getAuthorization(completion: @escaping(_ : Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    /// 通知権限をリクエストする関数
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                print("通知許可")
            } else {
                print("通知拒否")
            }
        }
    }
    /// ローカル通知を作成する関数
    /// - Parameters:
    ///   - name: 商品データの商品名
    ///   - notificationDate: 商品データの通知日時
    ///   - identifier: 商品データのUUIDの文字列
    func makeNotification(name: String, notificationDate: Date, identifier: String) {
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = "期限が近づいています"
        content.body = "商品名：\(name)"
        content.sound = .default
        // 日時指定(Itemの通知日時を使用)
        let notificationDate = notificationDate
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                            from: notificationDate)
        // トリガー指定
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        // リクエスト作成
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        // デリゲート設定
        notificationCenter.delegate = self
        // 通知をセット
        notificationCenter.add(request)
        print("通知作成")
//        UNUserNotificationCenter.current().getPendingNotificationRequests { array in
//            print("セットされた通知: \(array)")
//        }
    }
    /// 作成された通知を削除する関数
    /// - Parameter identifier: 商品データのUUIDの文字列
    func removeNotification(identifier: String) {
        // 通知削除
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("通知削除")
//        UNUserNotificationCenter.current().getPendingNotificationRequests { array in
//            print("セットされた通知: \(array)")
//        }
    }
    /// 通知をセットし直す関数
    /// - Parameter items: 通知が現在より後に設定された商品データ
    func resetNotification(items: FetchedResults<Item>) {
        print("通知ありのデータ：\(items.count)")
        // 全てのローカル通知を削除
        notificationCenter.removeAllPendingNotificationRequests()
        // データの数だけ
        for item in items {
            // オプショナルバインディング
            if let name = item.name,
               let notificationDate = item.notificationDate,
               let identifer = item.id?.uuidString {
                print("\(name), \(notificationDate)")
                // 通知作成
                makeNotification(name: name, notificationDate: notificationDate, identifier: identifer)
            }
        }
        notificationCenter.getPendingNotificationRequests { array in
            print("セットされた通知: \(array)")
        }
    }
}
