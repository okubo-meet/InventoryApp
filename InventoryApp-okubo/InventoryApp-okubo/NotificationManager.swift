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
    // ローカル通知を作成する関数
    func makeNotification(item: Item) {
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = "期限が近づいています"
        content.body = "フォルダ：\((item.folder?.name)!)\n商品名：\(item.name!)" // 改行あり
        content.sound = .default
        // 日時指定(Itemの通知日時を使用)
        let notificationDate = item.notificationDate!
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                            from: notificationDate)
        // トリガー指定
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        // 通知の識別ID(ItemのUUIDを使用)
        let identifier = "\(String(describing: item.id))"
        // リクエスト作成
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        // デリゲート設定
        UNUserNotificationCenter.current().delegate = self
        // 通知をセット
        UNUserNotificationCenter.current().add(request)
        print("通知作成")
    }
    // 作成された通知を削除する関数
    func removeNotification(item: Item) {
        // idをString型に変換
        let identifier = "\(String(describing: item.id))"
        // 通知削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("通知削除")
    }
}
