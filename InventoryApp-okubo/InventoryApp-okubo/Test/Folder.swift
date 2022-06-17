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
    let id = UUID()
    /// フォルダ名
    let name: String
    /// 在庫リストか買い物リストかの判定
    let isStock: Bool
    /// アイコン名
    let icon: String?
}
