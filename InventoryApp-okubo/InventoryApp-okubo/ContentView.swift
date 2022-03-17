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
    let namme: String
    /// 画像
    let image: UIImage
    /// 期限
    let deadLine: Date?
    /// 登録日
    let registrationDate: Date
    /// 個数
    let numberOfItems: Int
    /// 状態
    let status: String
    /// 緊急性
    let isHurry: Bool
    /// 通知する日付
    let notificationDate: Date?
    /// フォルダ
    let folder: String
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
class testData: ObservableObject {
    @Published var folders: [Folder] = [Folder(name: "食品", isStock: true, icon: "fork.knife"),
                                        Folder(name: "買い物リスト", isStock: false, icon: nil),
                                        Folder(name: "日用品", isStock: true, icon: "house.fill")]
    @Published var items: [ItemData] = [ItemData(namme: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "pork-loin"),
                                                 deadLine: Date(), registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "食品"),
                                        ItemData(namme: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "sardine"),
                                                 deadLine: Date(),
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "食品"),
                                        ItemData(namme: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "shampoo-hair-treatment"),
                                                 deadLine: nil,
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "開封済み",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "日用品"),
                                        ItemData(namme: "テスト",
                                                image: UIImage(imageLiteralResourceName: "shampoo-hair-treatment"),
                                                deadLine: nil,
                                                registrationDate: Date(),
                                                numberOfItems: 1,
                                                status: "未開封",
                                                isHurry: true,
                                                notificationDate: nil,
                                                folder: "買い物リスト"),
                                        ItemData(namme: "テスト",
                                                 image: UIImage(imageLiteralResourceName: "surgical-mask"),
                                                 deadLine: nil,
                                                 registrationDate: Date(),
                                                 numberOfItems: 1,
                                                 status: "未開封",
                                                 isHurry: false,
                                                 notificationDate: nil,
                                                 folder: "買い物リスト")]
}
