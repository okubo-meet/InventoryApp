//
//  NoFolderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/10/18.
//

import SwiftUI
import CoreData
// iCloud・CoreDataに登録されたデータがない場合のView
struct NoFolderView: View {
    // MARK: - プロパティ
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // フォルダデータの取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: true)],
                  animation: .default)
    private var folders: FetchedResults<Folder>
    // iCloudのデータをロード中の判定
//    @State private var importing = false
//    // iCloudの同期状態を通知するパブリッシャー
//    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    // iCloudの同期イベントを通知するクラス
    @ObservedObject var eventManager = EventManager()
    // MARK: - View
    var body: some View {
        VStack {
            Spacer()
            // 同期中の表示
            if eventManager.isImporting {
                Text("iCloudに同期中…")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                ProgressView()
                    .tint(.orange)
            } else {
                Text("フォルダがありません。")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Text("新規データを登録するにはフォルダが必要です。")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                Text("iCloudのデータに同期している場合はしばらくお待ちください。")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Button("初期フォルダ作成") {
                    makeFirstFolder()
                }
                .font(.title3)
                .foregroundColor(.white)
                .padding(.all)
                .background(Color.orange)
                .cornerRadius(10)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity,
               minHeight: 0, maxHeight: .infinity, alignment: .center)
        // 同期ステータスが変更された時の処理
//        .onReceive(publisher) { notification in
//            if let userInfo = notification.userInfo {
//                if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
//                    if event.type == .import {
//                        // データのインポート中
//                        importing = true
//                    } else {
//                        // 同期なし or データのインポート終了
//                        importing = false
//                    }
//                }
//            }
//        }
    }
    // MARK: - メソッド
    // フォルダの初期値を設定する関数（アプリ初回起動を想定）
    func makeFirstFolder() {
        // フォルダが一つも無い時
        if folders.count == 0 {
            print("初期データ作成")
            // 日用品フォルダ作成
            let dailyFolder = Folder(context: context)
            dailyFolder.id = UUID()
            dailyFolder.name = "日用品"
            dailyFolder.icon = Icon.house.rawValue
            dailyFolder.isStock = true
            // 食品フォルダ作成
            let foodFolder = Folder(context: context)
            foodFolder.id = UUID()
            foodFolder.name = "食品"
            foodFolder.icon = Icon.food.rawValue
            foodFolder.isStock = true
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

struct NoFolderView_Previews: PreviewProvider {
    static var previews: some View {
        NoFolderView()
    }
}
