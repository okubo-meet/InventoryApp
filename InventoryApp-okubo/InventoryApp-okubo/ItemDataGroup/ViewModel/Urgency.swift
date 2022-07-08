//
//  Urgency.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/08.
//

import Foundation
import SwiftUI
// 買い物の緊急性のクラス
class Urgency {
    // Pickerに表示する文字列
    let hurryString = "緊急"
    let notHurryString = "通常"
    // Listに表示する文字列を返す関数
    func toTextString(isHurry: Bool) -> String {
        if isHurry {
            return hurryString
        } else {
            return notHurryString
        }
    }
    // Listに表示するテキストの色を返す関数
    func toColor(isHurry: Bool) -> Color {
        if isHurry {
            return .red
        } else {
            return .blue
        }
    }
}