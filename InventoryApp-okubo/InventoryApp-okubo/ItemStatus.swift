//
//  ItemStatus.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/18.
//

import Foundation
import SwiftUI


enum ItemStatus: String, CaseIterable {
    case unOpened = "未開封"
    case opened = "開封済み"
    case low = "残りわずか"
    //状態を表すラベルの色を返す関数
    func toStatusColor() -> Color {
        switch self {
        case .unOpened:
            return .blue
        case .opened:
            return.gray
        case .low:
            return.red
        }
    }
}
