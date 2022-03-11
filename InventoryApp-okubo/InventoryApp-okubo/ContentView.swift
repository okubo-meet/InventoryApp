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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
