//
//  SettingView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
//設定画面　TabViewで扱うView
struct SettingView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("通知の許可")
                    Text("期限通知の時刻")
                }
                Section {
                    Text("iCloudの使用")
                    Text("ファミリー共有")
                }
                Section {
                    Text("広告の非表示")
                }
            }//Form
            .navigationTitle("設定")
        }// NavigationView
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
