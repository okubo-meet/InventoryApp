//
//  Folder.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/17.
//

import Foundation
// フォルダのデータ（テスト）
struct Folder: Identifiable {
    /// 識別ID
    var id = UUID()
    /// フォルダ名
    var name: String
    /// 在庫リストか買い物リストかの判定
    var isStock: Bool
    /// アイコン名
    var icon: String
}
