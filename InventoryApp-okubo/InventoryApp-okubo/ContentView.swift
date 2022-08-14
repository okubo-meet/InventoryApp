//
//  ContentView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/04.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - プロパティ
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // フォルダデータの取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: true)])
    private var folders: FetchedResults<Folder>
    // MARK: - View
    var body: some View {
        TabView {
            RegisterView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("登録")
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
        .onAppear {
            makeFirstFolder()
            NotificationManager().requestPermission()
        }
    }// body
    // MARK: - メソッド
    init() {
        // 背景色の設定
        UINavigationBar.appearance().backgroundColor = UIColor(Color.tabBar)
        UIToolbar.appearance().backgroundColor = UIColor(Color.tabBar)
        UITabBar.appearance().backgroundColor = UIColor(Color.tabBar)
        // SegmentedPickerStyleの設定
        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.selectedSegmentTintColor = UIColor.orange
        // 通常時の色
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
        // 選択時の色
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    // フォルダの初期値を設定する関数（アプリ初回起動を想定）
    func makeFirstFolder() {
        // フォルダが一つも無い時
        if folders.count == 0 {
            print("初期データ作成")
            // 食品フォルダ作成
            let foodFolder = Folder(context: context)
            foodFolder.id = UUID()
            foodFolder.name = "食品"
            foodFolder.icon = Icon.food.rawValue
            foodFolder.isStock = true
            // 日用品フォルダ作成
            let dailyFolder = Folder(context: context)
            dailyFolder.id = UUID()
            dailyFolder.name = "日用品"
            dailyFolder.icon = Icon.house.rawValue
            dailyFolder.isStock = true
            // 買い物フォルダ作成
            let buyFolder = Folder(context: context)
            buyFolder.id = UUID()
            buyFolder.name = "買い物リスト"
            buyFolder.icon = Icon.cart.rawValue
            buyFolder.isStock = false
            do {
                // 保存
                try context.save()
                print("初期フォルダ設定完了")
            } catch {
                print(error)
            }
        } else {
            print("データあり")
            for folder in folders {
                print(folder.name!)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
