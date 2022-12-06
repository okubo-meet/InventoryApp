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
    // MARK: - プロパティ
    // バックグラウンド・フォアグラウンドを検知する環境変数
    @Environment(\.scenePhase) var scenePhase
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // 通知日が現在より後に設定された商品データを取得
    @FetchRequest(entity: Item.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.registrationDate, ascending: true)],
                  predicate: NSPredicate(format: "notificationDate > %@", Date() as CVarArg))
    private var pendingItems: FetchedResults<Item>
    // 通知済みの商品データを取得
    @FetchRequest(entity: Item.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.registrationDate, ascending: true)],
                  predicate: NSPredicate(format: "notificationDate < %@", Date() as CVarArg))
    private var deliveredItems: FetchedResults<Item>
    // // iCloud使用許可を判定する変数
    @State private var accountAvailable = false
    // ローカル通知許可を判定する変数
    @State private var notificationAuth = false
    // アラート表示トリガー
    @State private var showAlert = false
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    //　効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("設定アプリを開く") {
                        let url = URL(string: UIApplication.openSettingsURLString)
                        UIApplication.shared.open(url!)
                    }
                    .font(.body)
                    .fontWeight(.medium)
                } header: {
                    Text("各種設定")
                }
                Section {
                    // iCloudの状態
                    SettingRowView(title: "iCloud",
                                   iconName: "cloud",
                                   text: accountStatusText())
                    // カメラの使用許可
                    SettingRowView(title: "カメラ",
                                   iconName: "camera",
                                   text: CameraManager.accessText())
                    // ローカル通知の許可
                    SettingRowView(title: "通知",
                                   iconName: "bell",
                                   text: notificationText())
                } header: {
                    Text("アプリの状態")
                }
                if notificationAuth {
                    Section {
                        Button("通知の再設定") {
                            // 通知再設定
                            notificationManager.resetNotification(items: pendingItems)
                            // 通知済みのデータの通知日をnilにする
                            for item in deliveredItems {
                                item.notificationDate = nil
                            }
                            do {
                                // 保存
                                try context.save()
                            } catch {
                                print(error)
                            }
                            // 効果音
                            soundPlayer.saveSoundPlay()
                            // アラート表示
                            showAlert.toggle()
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    } footer: {
                        Text("通知を作り直し、通知済みの商品データを更新します")
                    }
                }
            }// Form
            .navigationTitle("設定")
            // 通知更新完了アラート
            .alert("通知の更新が完了しました", isPresented: $showAlert, actions: {}, message: {
                Text("通知済みの商品データも更新されました")
            })
        }// NavigationStack
        .onAppear {
            // iCloudアカウントを取得
            getAccountStatus()
        }
        // フォアグラウンドを検知
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // 通知の権限取得
                notificationManager.getAuthorization(completion: getAuth(authorized:))
            }
        }
    }
    // iCloudアカウントの状態を取得する関数
    private func getAccountStatus() {
        CKContainer.default().accountStatus { status, error in
            if let error = error {
                print("iCloudアカウントの状態確認に失敗: \(error.localizedDescription)")
                accountAvailable = false
            } else {
                if status == .available {
                    accountAvailable = true
                } else {
                    accountAvailable = false
                }
            }
        }
    }
    // iCloudアカウントの状態の文字列を返す関数
    private func accountStatusText() -> String {
        if accountAvailable {
            return "利用可能"
        } else {
            return "利用不可"
        }
    }
    // 通知権限の文字列を返す関数
    private func notificationText() -> String {
        if notificationAuth {
            return "許可"
        } else {
            return "拒否"
        }
    }
    // 通知権限を取得するクロージャの引数
    private func getAuth(authorized: Bool) {
        notificationAuth = authorized
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
