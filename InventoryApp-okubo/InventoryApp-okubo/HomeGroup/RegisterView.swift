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
    // バーコード読み取り画面を呼び出すフラグ
    @State private var showSheet = false
    // 新規登録するデータの配列(リスト表示する)
    @State private var newItems: [ItemData] = []
    // MARK: - View
    var body: some View {
        VStack {
            Picker("", selection: $isStock) {
                Text("在庫リスト").tag(true)
                Text("買い物リスト").tag(false)
            }
            .pickerStyle(.segmented)
            if newItems.isEmpty {
                Spacer()
                Text("追加するデータがありません")
                    .foregroundColor(.gray)
                    .font(.title)
                Text("「追加」を押すことでデータを作成できます")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(0..<newItems.count, id: \.self) { index in
                        // TODO: - バーコードを複数読み取った場合のデータを受け取る。
                        NavigationLink(destination: ItemDataView(isStock: $isStock,
                                                                 itemData: $newItems[index])) {
                            RegisterRowView(itemData: newItems[index])
                        }
                    }
                    .onDelete(perform: rowRemove)
                }// List
            }
        }// VStack
        .sheet(isPresented: $showSheet) {
            BarcodeReaderView(item: $newItems.last!)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("商品登録")
        .toolbar {
            // 画面右上
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button("登録") {
                    // 商品登録の処理(テスト)
                    for newData in newItems {
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
                    Button(action: {
                        // 配列の最後尾が空のデータでないときは新規データを作成してシートを起動
                        if newItems.isEmpty {
                            newItems.append(ItemData(folder: "食品"))
                        } else if newItems.last?.name != "" || newItems.last?.image != nil {
                            newItems.append(ItemData(folder: "食品"))
                        }
                        showSheet = true
                    }, label: {
                        Image(systemName: "barcode.viewfinder")
                    })
                    Spacer()
                    Button("追加") {
                        // TODO: - 一度に追加できるデータに上限を設ける
                        // 空のデータ追加
                        newItems.append(ItemData(folder: "食品"))
                    }
                }// HStack
            })
        }// toolbar
    }
    // MARK: - メソッド
    // リストの行を削除する関数
    private func rowRemove(offsets: IndexSet) {
        newItems.remove(atOffsets: offsets)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
