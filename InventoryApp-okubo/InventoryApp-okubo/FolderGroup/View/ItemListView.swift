//
//  ItemListView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/09.
//

import SwiftUI
// 商品データをリスト表示する画面
struct ItemListView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 遷移先で表示するデータのインデックス番号
    @State private var indexNum = 0
    // リストから遷移するフラグ
    @State private var isActive = false
    // 編集モードの切り替えフラグ
    @State private var isEditing = false
    // ダイアログ表示トリガー
    @State private var showDialog = false
    // 選択されたデータを保持する配列
    @State private var selectedItemID: [UUID] = []
    // どのカテゴリのリストかを受け取る変数
    var folder: FolderData
    // MARK: - View
    var body: some View {
        ZStack {
            VStack {
                List(folderItems(folderName: folder.name)) { item in
                    HStack {
                        // 編集モードのときのみ表示するアイコン
                        if isEditing {
                            Image(systemName: selectIconString(id: item.id))
                                .foregroundColor(isSelected(id: item.id) ? .red : .gray)
                        }
                        // 同じフォルダに登録されたデータリスト
                        ListRowView(item: item, isStock: folder.isStock)
                            .onTapGesture {
                                // 編集モードのとき
                                if isEditing {
                                    // 既に選択されたデータなら選択解除
                                    if isSelected(id: item.id) {
                                        if let index = selectedItemID.firstIndex(of: item.id) {
                                            print("選択解除")
                                            selectedItemID.remove(at: index)
                                        }
                                    } else {
                                        print("選択")
                                        // 選択状態にする
                                        selectedItemID.append(item.id)
                                    }
                                } else {
                                    // 編集モードでない時は画面遷移
                                    showItemView(item: item)
                                }
                            }
                        // 画面遷移を表すアイコン
                        if isEditing == false {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }// HStack
                }// List
                .listStyle(.plain)
            }// VStack
            // 商品データが無い場合の表示
            if folderItems(folderName: folder.name).isEmpty {
                VStack {
                    Spacer()
                    Text("データがありません")
                        .font(.title)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            NavigationLink(destination: ItemDataView(itemData: $testData.items[indexNum]),
                           isActive: $isActive) {
                EmptyView()
            }
                           .navigationTitle(folder.name)
        }// ZStack
        // データ削除ダイアログ
        .confirmationDialog("選択したデータを削除します", isPresented: $showDialog, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                withAnimation {
                    // 選択されたidで検索してデータを削除する
                    for uuid in selectedItemID {
                        if let index = testData.items.firstIndex(where: {$0.id == uuid}) {
                            testData.items.remove(at: index)
                        }
                    }
                    // 編集モード終了
                    isEditing.toggle()
                    selectedItemID.removeAll()
                }
            }
        }
        .navigationTitle(navigationTitleString())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            // 編集モード切り替えボタン
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button(action: {
                    // 編集モード起動
                    withAnimation {
                        selectedItemID.removeAll()
                        isEditing.toggle()
                    }
                }, label: {
                    if isEditing {
                        Text("キャンセル")
                    } else {
                        Text("編集")
                    }
                })
                .disabled(folderItems(folderName: folder.name).isEmpty)// フォルダ内のデータが無い時は無効
            })
            // ボトムバー
            ToolbarItem(placement: .bottomBar, content: {
                // 編集モードのときのみ表示
                if isEditing {
                    HStack {
                        Spacer()
                        // 削除ボタン
                        Button("削除") {
                            // 削除ダイアログ表示
                            showDialog.toggle()
                        }
                        .disabled(selectedItemID.isEmpty)
                    }// HStack
                }
            })
        })// toolbar
    }
    // MARK: - メソッド
    // フォルダ名から商品リストを検索して返す関数
    private func folderItems(folderName: String) -> [ItemData] {
        let items = testData.items.filter({$0.folder == folderName})
        return items
    }
    // データから配列のインデックス番号を検索し、NavigationLinkを起動する関数
    private func showItemView(item: ItemData) {
        if let index = testData.items.firstIndex(where: { $0.id == item.id }) {
            indexNum = index
            print("インデックス番号: \(indexNum)")
            isActive = true
        }
    }
    // 編集モードで選択されたデータかの判定を返す関数
    private func isSelected(id: UUID) -> Bool {
        let isSelected = selectedItemID.contains(where: {$0 == id})
        return isSelected
    }
    // 編集モードで選択されたデータのアイコンを切り替える関数
    private func selectIconString(id: UUID) -> String {
        if isSelected(id: id) {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }
    // navigationTitleに表示する文字列を返す関数
    private func navigationTitleString() -> String {
        if selectedItemID.isEmpty {
            return folder.name
        } else {
            return "\(selectedItemID.count)個選択"
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(folder: TestData().folders[0])
    }
}
