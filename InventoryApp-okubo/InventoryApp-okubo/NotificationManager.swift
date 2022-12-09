//
//  NotificationManager.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/08/14.
//

import Foundation
import UserNotifications

// 通知を扱うクラス
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // フォアグラウンド通知デリゲートメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    // 通知権限をリクエストする関数
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
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
        UNUserNotificationCenter.current().delegate = self
        // 通知をセット
        UNUserNotificationCenter.current().add(request)
        print("通知作成")
//        UNUserNotificationCenter.current().getPendingNotificationRequests { array in
//            print("セットされた通知: \(array)")
//        }
    }
    /// 作成された通知を削除する関数
    /// - Parameter identifier: 商品データのUUIDの文字列
    func removeNotification(identifier: String) {
        // 通知削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("通知削除")
//        UNUserNotificationCenter.current().getPendingNotificationRequests { array in
//            print("セットされた通知: \(array)")
//        }
    }
}
