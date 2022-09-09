//
//  SettingView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
// 設定画面　TabViewで扱うView
struct SettingView: View {
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("通知の許可") {
                        let url = URL(string: UIApplication.openSettingsURLString)
                        UIApplication.shared.open(url!)
                    }
                } header: {
                    Text("通知設定")
                }
                Section {
                    Text("iCloudの使用")
                    Text("ファミリー共有")
                } header: {
                    Text("iCloud設定")
                }
                Section {
                    Text("広告の非表示")
                }
            }// Form
            .navigationTitle("設定")
        }// NavigationView
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
