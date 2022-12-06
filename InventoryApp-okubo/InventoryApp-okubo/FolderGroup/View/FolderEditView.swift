//
//  FolderEditView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/08.
//

import SwiftUI
// フォルダを編集する画面
struct FolderEditView: View {
    // MARK: - プロパティ
    // 環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // フォルダデータの取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: false)])
    private var folders: FetchedResults<Folder>
    // 編集するフォルダのID
    @Binding var folderID: UUID?
    // 編集中のフォルダ名
    @State private var editName = ""
    //　編集中のフォルダの種類
    @State private var editStock = true
    // 編集中のフォルダのアイコン名
    @State private var editIcon = Icon.house.rawValue
    // フォルダ保存アラートのフラグ
    @State private var saveAlert = false
    // フォルダ削除アラートのフラグ
    @State private var deleteAlert = false
    // フォルダ名のTextFieldのフォーカス
    @FocusState private var focusState: Bool
    // 効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("フォルダ名:")
                        TextField("入力してください", text: $editName)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusState)
                            .fontWeight(.medium)
                    }
                    Picker("タイプ", selection: $editStock, content: {
                        Text("在庫リスト").tag(true)
                        Text("買い物リスト").tag(false)
                    })
                    .disabled(isLastFolder())
                    Picker("アイコン", selection: $editIcon, content: {
                        ForEach(Icon.allCases, id: \.self) { icon in
                            Image(systemName: icon.rawValue).tag(icon.rawValue)
                                .foregroundColor(.orange)
                        }
                    })
                }
                Section {
                    // 既存フォルダの削除ボタン
                    if folderID != nil {
                        Button(action: {
                            // 削除アラート起動
                            deleteAlert.toggle()
                            soundPlayer.deleteVibrationPlay()
                            focusState = false
                        }, label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("フォルダを削除する")
                            }
                            .foregroundColor(isLastFolder() ? .gray : .red)
                        })
                        .disabled(isLastFolder())
                    }
                } footer: {
                    // 編集機能を制限する際に表示
                    if isLastFolder() {
                        VStack {
                            Text("このフォルダは削除及び、タイプ変更できません。")
                            Text("各タイプのフォルダが１つ以上存在している必要があります。")
                        }
                        .fontWeight(.medium)
                    }
                }
            }// Form
            // 保存アラート
            .alert("フォルダを保存しました", isPresented: $saveAlert, actions: {
                Button("OK") {
                    dismiss()
                }
            }, message: {
                Text("前の画面に戻ります")
            })
            // 削除アラート
            .alert("フォルダを削除します", isPresented: $deleteAlert, actions: {
                Button("削除", role: .destructive) {
                    // CoreDataから該当するIDのフォルダを削除
                    deleteFolder()
                    dismiss()
                }
            }, message: {
                Text("このフォルダに保存されたデータも削除されます")
            })
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
                        if let index = folderIndex() {
                            // 更新
                            updateFolder(index: index)
                        } else {
                            // 新規フォルダ追加
                            addNewFolder()
                        }
                        // 保存完了アラート起動
                        saveAlert.toggle()
                        soundPlayer.saveSoundPlay()
                    }
                    .disabled(editName == "" || isNoChange())// フォルダ名が無いか、どの項目にも変更がない場合無効化
                })
                // キーボードを閉じるボタン
                ToolbarItemGroup(placement: .keyboard, content: {
                    Spacer()
                    Button("閉じる") {
                        focusState = false
                    }
                    .foregroundColor(.blue)
                })
            })// toolbar
        }// NavigationStack
        .onAppear {
            // 入力欄にIDが一致したフォルダの値を代入する
            if let index = folderIndex() {
                print("既存のフォルダ：" + folders[index].name!)
                editName = folders[index].name!
                editIcon = folders[index].icon!
                editStock = folders[index].isStock
            } else {
                print("新規作成")
            }
        }
    }// View
    // MARK: - メソッド
    // IDが一致したフォルダのインデックス番号を返す関数
    private func folderIndex() -> Int? {
        if let index = folders.firstIndex(where: {$0.id == folderID}) {
            return index
        } else {
            //            print("IDが一致するフォルダがありません")
            return nil
        }
    }
    //  入力情報で新規フォルダを保存する関数
    private func addNewFolder() {
        let newFolder = Folder(context: context)
        newFolder.id = UUID()
        newFolder.name = editName
        newFolder.icon = editIcon
        newFolder.isStock = editStock
        do {
            // 保存
            try context.save()
            print("フォルダ追加完了")
        } catch {
            print(error)
        }
    }
    // 入力情報で既存フォルダを上書きする関数
    private func updateFolder(index: Int) {
        // 上書き
        folders[index].name = editName
        folders[index].icon = editIcon
        folders[index].isStock = editStock
        do {
            // 保存
            try context.save()
            print("フォルダ上書き完了")
        } catch {
            print(error)
        }
    }
    // idが一致するフォルダをCoreDataから削除する関数
    private func deleteFolder() {
        guard let index = folderIndex() else {
            return
        }
        // フォルダ内の商品データを取得
        let items = folderItems(items: folders[index].items)
        for item in items {
            // ローカル通知の識別ID
            if let identifier = item.id?.uuidString {
                // 通知を削除
                notificationManager.removeNotification(identifier: identifier)
            }
            // 商品データ削除
            context.delete(item)
        }
        // フォルダ削除
        context.delete(folders[index])
        do {
            // 保存
            try context.save()
            print("フォルダ削除完了")
        } catch {
            print(error)
        }
    }
    // フォルダ内の商品を検索して返す関数
    private func folderItems(items: NSSet?) -> [Item] {
        // NSSet? を [Item]に変換
        if let setItems = items as? Set<Item> {
            // 通知が設定されている商品の配列を返す
            return setItems.sorted(by: {$0.registrationDate! < $1.registrationDate!})
        } else {
            return []
        }
    }
    // 編集しているフォルダと同じ種類のフォルダの存在をチェックする関数
    private func isLastFolder() -> Bool {
        // 編集か新規作成か判定
        if let index = folderIndex() {
            // 編集中のフォルダのタイプを取得
            let isStock = folders[index].isStock
            // 種類が一致しているものを抽出
            let searchedFolders = folders.filter({$0.isStock == isStock})
            // １つしかない場合は削除やタイプを変更をできないようにする
            if searchedFolders.count == 1 {
                return true
            }
        }
        return false
    }
    // 編集フォルダに変更がない時は保存ボタンを無効化する関数
    private func isNoChange() -> Bool {
        // 既存フォルダの編集か判定
        if let index = folderIndex() {
            // 全ての項目に変更がない場合は保存ボタンを無効化
            if folders[index].name == editName
                && folders[index].isStock == editStock
                && folders[index].icon == editIcon {
                // 変更無し
                return true
            }
        }
        // 新規作成 or 変更点あり
        return false
    }
}

struct FolderEditView_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditView(folderID: .constant(nil))
    }
}
