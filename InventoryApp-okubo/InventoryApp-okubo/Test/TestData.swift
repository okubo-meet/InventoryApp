//
//  TestData.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/17.
//

import Foundation
import SwiftUI
// テストデータ
class TestData: ObservableObject {
    @Published var folders: [FolderData] = [FolderData(name: "食品", isStock: true, icon: Icon.food.rawValue),
                                        FolderData(name: "買い物リスト", isStock: false, icon: Icon.cart.rawValue),
                                        FolderData(name: "日用品", isStock: true, icon: Icon.house.rawValue)]
    @Published var items: [ItemData] = [ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "pork-loin").pngData(),
                                                 deadLine: Date(), registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "食品"),
                                        ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "sardine").pngData(),
                                                 deadLine: Date(),
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "食品"),
                                        ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName:
                                                                    "shampoo-hair-treatment").pngData(),
                                                 deadLine: nil,
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "開封済み",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "日用品"),
                                        ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName:
                                                                    "shampoo-hair-treatment").pngData(),
                                                deadLine: nil,
                                                registrationDate: Date(),
                                                numberOfItems: 1,
                                                status: "未開封",
                                                isHurry: true,
                                                notificationDate: nil,
                                                folder: "買い物リスト"),
                                        ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "surgical-mask").pngData(),
                                                 deadLine: nil,
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "買い物リスト")]
}
