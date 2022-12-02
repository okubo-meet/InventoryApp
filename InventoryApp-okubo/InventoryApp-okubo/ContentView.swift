//
//  ContentView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/04.
//

import SwiftUI

struct ContentView: View {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
