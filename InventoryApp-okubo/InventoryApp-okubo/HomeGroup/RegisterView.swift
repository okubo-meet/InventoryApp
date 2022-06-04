//
//  RegisterView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/08.
//

import SwiftUI
// 商品登録画面
struct RegisterView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 在庫リストか買い物リストどちらに登録するかの判定
    @State private var isStock = true
    // 遷移先で表示するデータのインデックス番号
    @State private var indexNum = 0
    // リストから遷移するフラグ
    @State private var isActive = false
    // MARK: - View
    var body: some View {
        VStack {
            Picker("", selection: $isStock) {
                Text("在庫リスト").tag(true)
                Text("買い物リスト").tag(false)
            }
            .pickerStyle(.segmented)
            if testData.newItem.isEmpty {
                Spacer()
                Text("追加するデータがありません")
                    .foregroundColor(.gray)
                    .font(.title)
                Spacer()
            } else {
                // TODO: - データをに変更が加わると勝手に画面が閉じてしまう問題を修正する
                List {
                    ForEach(testData.newItem) { item in
                        RegisterRowView(itemData: item)
                            .onTapGesture {
                                showItemView(item: item)
                            }
                    }
                    .onDelete(perform: rowRemove)
                }
                // 商品データ画面のリンク
                NavigationLink(destination: ItemDataView(isStock: $isStock,
                                                         itemData: $testData.newItem[indexNum]), isActive: $isActive) {
                    EmptyView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("商品登録")
        .toolbar {
            // 画面右上
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button("登録") {
                    // 商品登録の処理
                    for newData in testData.newItem {
                        print("追加するデータ: \(newData)")
                        testData.items.append(newData)
                    }
                }
            })
            // 画面下部
            ToolbarItem(placement: .bottomBar, content: {
                HStack {
                    // 編集モード起動ボタン
                    EditButton()
                    Spacer()
                    Button("商品追加") {
                        // 空のデータ追加
                        testData.newItem.append(ItemData(folder: "食品"))
                    }
                }// HStack
            })
        }// toolbar
    }
    // MARK: - メソッド
    // リストの行を削除する関数
    private func rowRemove(offsets: IndexSet) {
        testData.newItem.remove(atOffsets: offsets)
    }
    // データから配列のインデックス番号を検索し、NavigationLinkを起動する関数
    private func showItemView(item: ItemData) {
        if let index = testData.newItem.firstIndex(where: { $0.id == item.id }) {
            indexNum = index
            print("インデックス番号: \(indexNum)")
            isActive = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
