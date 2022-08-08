//
//  ItemData.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/17.
//

import Foundation
// 商品データ（データ編集に使用）
struct ItemData: Identifiable {
    /// 識別ID
    var id = UUID()
    /// 商品名
    var name: String = ""
    /// 画像
    var image: Data?
    /// 期限
    var deadLine: Date?
    /// 登録日
    var registrationDate: Date = Date()
    /// 個数
    var numberOfItems: Int16 = 1
    /// 状態
    var status: String = ItemStatus.unOpened.rawValue
    /// 緊急性
    var isHurry: Bool = false
    /// 通知する日付
    var notificationDate: Date?
    /// フォルダ
    var folder: Folder?
}
