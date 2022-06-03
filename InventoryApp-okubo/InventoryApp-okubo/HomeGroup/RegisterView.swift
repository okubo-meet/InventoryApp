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
                List {
                    ForEach(testData.newItem) { item in
                        // TODO: - リストのアイテム表示は新たに作る
                        ListRowView(item: item, isStock: isStock)
                    }
                    .onDelete(perform: rowRemove)
                }
            }
            // 商品データ
//            ItemDataView(isStock: $isStock, itemData: $testData.newItem)
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
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
