//
//  SettingView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
import CloudKit
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
    // iCloudアカウントの状態をチェックする関数
    func accountRequest() {
        CKContainer.default().accountStatus { status, error in
            if let error = error {
                print("iCloudアカウントの状態確認に失敗: \(error.localizedDescription)")
            }
            switch status {
            case .available:
                print("iCloudアカウントが利用可能")
            case .couldNotDetermine:
                print("状態を判断できなかった")
            case .restricted:
                print("iCloudアカウントへのアクセスを拒否")
            case .noAccount:
                print("iCloudアカウントにログインされていない")
            case .temporarilyUnavailable:
                print("iCloudアカウントは一時的に利用できません")
            @unknown default:
                print("iCloudアカウントの不明なエラー")
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
