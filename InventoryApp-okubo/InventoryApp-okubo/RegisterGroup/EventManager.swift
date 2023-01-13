//
//  EventManager.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/12/22.
//

import Foundation
import CoreData
// iCloudの同期状態を通知するクラス
class EventManager: ObservableObject {
    // iCloudのデータをロード中の判定
    @Published var isImporting = false
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(eventChange(_:)), name: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
    }
    @objc private func eventChange(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
                DispatchQueue.main.async {
                    if event.type == .import {
                        // データのインポート中
                        print("データのインポート中")
                        self.isImporting = true
                    } else {
                        // 同期なし or データのインポート終了
                        print("同期なし or データのインポート終了")
                        self.isImporting = false
                    }
                }
            }
        }
    }
}
