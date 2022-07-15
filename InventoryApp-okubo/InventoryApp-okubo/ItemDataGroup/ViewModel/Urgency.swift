//
//  Urgency.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/08.
//

import Foundation
import SwiftUI
// 買い物の緊急性の列挙型
enum Urgency: String {
    case hurry = "緊急"
    case normal = "通常"
    // 買い物データの緊急性の値で初期化する
    init(isHurry: Bool) {
        if isHurry {
            self = .hurry
        } else {
            self = .normal
        }
    }
    // Listに表示するテキストの色を返す関数
    func color() -> Color {
        switch self {
        case .hurry:
            return .red
        case .normal:
            return .blue
        }
    }
}
