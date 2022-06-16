//
//  FolderEditView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/16.
//

import SwiftUI
// フォルダを編集する画面
struct FolderEditView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    // 編集するフォルダ
    @State var folder: Folder
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                TextField("フォルダ名", text: $folder.name)
                Picker("種類", selection: $folder.isStock, content: {
                    Text("在庫リスト").tag(true)
                    Text("買い物リスト").tag(false)
                })
                Picker("アイコン", selection: $folder.icon, content: {
                    ForEach(Icon.allCases, id: \.self) { icon in
                        Image(systemName: icon.rawValue).tag(icon.rawValue)
                            .foregroundColor(.orange)
                    }
                })
                // TODO: - 削除ボタンを追加する
            }
            .navigationTitle("フォルダ設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                // 画面を閉じるボタン
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("閉じる") {
                        dismiss()
                    }
                })
                // 保存ボタン
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("保存") {
                        // フォルダ設定保存の処理
                        if let index = testData.folders.firstIndex(where: {$0.id == folder.id}) {
                            // 更新
                            testData.folders[index] = folder
                        } else {
                            // 追加
                            testData.folders.append(folder)
                        }
                        // TODO: - 保存完了アラートを作成する
                        dismiss()
                    }
                })
            })// toolbar
        }// NavigationView
    }// View
}

struct FolderEditView_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditView(folder: .init(name: "", isStock: true, icon: "無し"))
    }
}
