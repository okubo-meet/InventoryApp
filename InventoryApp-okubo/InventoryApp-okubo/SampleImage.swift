//
//  SampleImage.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/11.
//

import Foundation

enum SampleImage: String, CaseIterable {
    case food = "食品"
    case daily = "日用品"
    case medical = "医薬品"
    case lifestyle = "娯楽"
    case fasion = "衣類"
    //それぞれのカテゴリの画像ファイル名の配列を返す
    func toImageString() -> [String] {
        switch self {
        case .food:
            return ["pork-loin", "sardine", "shijimi-clams",
                    "vegetables-various", "fruits", "mushroom-various",
                    "water-plastic-bottle-2l", "milk"]
        case .daily:
            return ["kleenex-box", "toilet-paper", "cleaning-equipment",
                    "shampoo-hair-treatment", "paper-pencil", "packaging-tape"]
        case .medical:
            return ["band-aid", "medicine", "supplement", "surgical-mask"]
        case .lifestyle:
            return ["books", "handheld-game-console", "headphones",
                    "spinlock-dumbbell", "toys"]
        case .fasion:
            return ["striped-shirt-blue", "jeans", "skirt",
                    "socks", "sneakers-blue", "trench-coat"]
        }
    }
}
