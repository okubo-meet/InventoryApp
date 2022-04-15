//
//  ContentView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            FolderView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("フォルダ")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
    }// body
    
    init() {
        //TabViewの背景色の設定
        UITabBar.appearance().backgroundColor = UIColor(Color.tabBar)
        //SegmentedPickerStyleの設定
        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.selectedSegmentTintColor = UIColor.orange
        //通常時の色
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
        //選択時の色
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//商品データ（テスト）
struct ItemData: Identifiable {
    /// 識別ID
    let id = UUID()
    /// 商品名
    var name: String = ""
    /// 画像
    var image: Data? = nil
    /// 期限
    var deadLine: Date?
    /// 登録日
    var registrationDate: Date = Date()
    /// 個数
    var numberOfItems: Int = 1
    /// 状態
    var status: String = "未開封"
    /// 緊急性
    var isHurry: Bool = false
    /// 通知する日付
    var notificationDate: Date?
    /// フォルダ
    var folder: String
}
//フォルダのデータ（テスト）
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
// テストデータ
class TestData: ObservableObject {
    @Published var newItem = ItemData(folder: "食品")
    @Published var folders: [Folder] = [Folder(name: "食品", isStock: true, icon: "fork.knife"),
                                        Folder(name: "買い物リスト", isStock: false, icon: nil),
                                        Folder(name: "日用品", isStock: true, icon: "house.fill")]
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
                                                 image: UIImage(imageLiteralResourceName: "shampoo-hair-treatment").pngData(),
                                                 deadLine: nil,
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "開封済み",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "日用品"),
                                        ItemData(name: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "shampoo-hair-treatment").pngData(),
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
