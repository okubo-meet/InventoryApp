//
//  SearchResult.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/05/16.
//

import Foundation

///API検索結果の列挙型
enum SearchResult {
    ///成功
    case success
    ///該当商品無し
    case failure
    ///エラー
    case error
}
