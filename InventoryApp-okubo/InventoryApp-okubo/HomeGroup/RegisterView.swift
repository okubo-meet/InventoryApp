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
    // 登録完了アラートのフラグ
    @State private var saveAlert = false
    // 名前のないデータに対するアラートのフラグ
    @State private var noNameAlert = false
    // バーコード読み取り画面を呼び出すフラグ
    @State private var showSheet = false
    // 新規登録するデータの配列(リスト表示する)
    @State private var newItems: [ItemData] = []
    //　効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    // 新規登録データの上限値
    private let maxItems = 10
    // MARK: - View
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    List {
                        ForEach(0..<newItems.count, id: \.self) { index in
                            NavigationLink(destination: ItemDataView(itemData: $newItems[index])) {
                                RegisterRowView(itemData: newItems[index])
                            }
                        }
                        .onDelete(perform: rowRemove)
                    }// List
                    Text("\(newItems.count)/\(maxItems)")
                        .font(.callout)
                }
                if newItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("登録するデータがありません")
                            .font(.title)
                            .padding(.bottom)
                        Text("「追加」を押してデータを作成する。")
                        Text(Image(systemName: "barcode.viewfinder")) + Text("バーコードを読み取って作成する。")
                        Spacer()
                    }
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity,
                           minHeight: 0, maxHeight: .infinity, alignment: .center)
                }
            }// ZStack
        }// VStack
        .alert("登録完了", isPresented: $saveAlert, actions: {
            Button("OK") {
                withAnimation {
                    newItems.removeAll()
                }
            }
        })
        .alert("商品名のないデータがあります", isPresented: $noNameAlert, actions: {
            // 処理無し
        }, message: {
            Text("商品名を設定するか、データを削除してください")
        })
        .sheet(isPresented: $showSheet, onDismiss: {
            // この配列の先頭はバーコードリーダーでリストに反映してるので２つ以上読み取っている場合の処理
            if RakutenAPI.resultItems.count >= 2 {
                // 先頭は必要ない
                RakutenAPI.resultItems.removeFirst()
                // リストに加える
                for item in RakutenAPI.resultItems {
                    newItems.append(item)
                }
            }
            RakutenAPI.resultItems.removeAll()
        }, content: {
            BarcodeReaderView(item: $newItems.last!, isItemEdit: false)
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("商品登録")
        .toolbar {
            // 画面右上
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button("登録") {
                    // 名前が入力されていないデータがあるときはアラート表示
                    if newItems.allSatisfy({$0.name != ""}) {
                        // 商品登録の処理(テスト)
                        for newItem in newItems {
                            print("追加するデータ: \(newItem)")
                            testData.items.append(newItem)
                        }
                        saveAlert.toggle()
                        soundPlayer.saveSoundPlay()
                    } else {
                        noNameAlert.toggle()
                    }
                }
                .disabled(newItems.isEmpty)
            })
            // ボトムバー
            ToolbarItem(placement: .bottomBar, content: {
                HStack {
                    // 編集モード起動ボタン
                    EditButton()
                        .disabled(newItems.isEmpty)
                    Spacer()
                    // バーコードリーダー呼び出しボタン
                    Button(action: {
                        // 配列の最後尾が空のデータでないときは新規データを作成してシートを起動
                        if newItems.isEmpty {
                            newItems.append(ItemData(folder: "食品"))
                        } else if newItems.last?.name != "" || newItems.last?.image != nil {
                            newItems.append(ItemData(folder: "食品"))
                        }
                        // 読み取り上限を設定 リストの最後尾はBindingで渡すのでカウントしない
                        let number = newItems.count - 1
                        RakutenAPI.readLimit = maxItems - number
                        RakutenAPI.resultItems.removeAll()
                        showSheet.toggle()
                    }, label: {
                        Image(systemName: "barcode.viewfinder")
                    })
                    .disabled(newItems.count == maxItems)
                    Spacer()
                    Button("作成") {
                        // 空のデータ追加
                        withAnimation {
                            newItems.append(ItemData(folder: "食品"))
                        }
                    }
                    .disabled(newItems.count == maxItems)
                }// HStack
            })
        }// toolbar
    }
    // MARK: - メソッド
    // ForEachの.onDeleteに渡す関数
    private func rowRemove(offsets: IndexSet) {
        newItems.remove(atOffsets: offsets)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
