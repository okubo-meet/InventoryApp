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
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // フォルダデータの取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: false)],
                  animation: .default)
    private var folders: FetchedResults<Folder>
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
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // 新規登録データの上限値
    private let maxItems = 10
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                // メニューバー
                HStack {
                    Spacer()
                    // 空のデータ追加ボタン
                    Button("作成") {
                        withAnimation {
                            addNewItem()
                        }
                    }
                    .disabled(newItems.count == maxItems || folders.isEmpty)
                    Spacer()
                    // バーコードリーダー呼び出しボタン
                    Button(action: {
                        // 配列の最後尾が空のデータでないときは新規データを作成してシートを起動
                        if newItems.isEmpty {
                            addNewItem()
                        } else if newItems.last?.name != "" || newItems.last?.image != nil {
                            addNewItem()
                        }
                        // 読み取り上限を設定 リストの最後尾はBindingで渡すのでカウントしない
                        let number = newItems.count - 1
                        RakutenAPI.readLimit = maxItems - number
                        RakutenAPI.resultItems.removeAll()
                        showSheet.toggle()
                    }, label: {
                        Image(systemName: "barcode.viewfinder")
                    })
                    .disabled(newItems.count == maxItems || folders.isEmpty)
                    Spacer()
                    // 登録ボタン
                    Button("登録") {
                        // 名前が入力されていないデータがあるときはアラート表示
                        if newItems.allSatisfy({$0.name != ""}) {
                            // 商品登録
                            saveItem()
                        } else {
                            noNameAlert.toggle()
                        }
                    }
                    .disabled(newItems.isEmpty)
                    Spacer()
                }// HStack
                ZStack {
                    VStack {
                        // 新規作成データリスト
                        List {
                            ForEach(0..<newItems.count, id: \.self) { index in
                                NavigationLink(destination: ItemDataView(itemData: $newItems[index],
                                                                         isFolderItem: false)) {
                                    RegisterRowView(itemData: newItems[index])
                                }
                            }
                            .onDelete(perform: rowRemove)
                        }// List
                        if folders.count != 0 {
                            Text("\(newItems.count)/\(maxItems)")
                                .font(.callout)
                        }
                    }
                    if newItems.isEmpty {
                        if folders.isEmpty {
                            // フォルダが一つもない場合の表示
                            NoFolderView()
                        } else {
                            // 新規作成可能
                            VStack {
                                Spacer()
                                Text("登録するデータがありません")
                                    .font(.title)
                                    .padding(.bottom)
                                Text("「作成」を押してデータを作成する。")
                                Text(Image(systemName: "barcode.viewfinder")) + Text("バーコードを読み取って作成する。")
                                Text("データは左スワイプで削除できる。")
                                Spacer()
                            }
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity,
                                   minHeight: 0, maxHeight: .infinity, alignment: .center)
                        }
                    }
                }// ZStack
            }// VStack
            // MARK: - アラート
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
            // MARK: - シート
            .sheet(isPresented: $showSheet, onDismiss: {
                // この配列の先頭はバーコードリーダーでリストに反映してるので２つ以上読み取っている場合の処理
                if RakutenAPI.resultItems.count >= 2 {
                    // 先頭は必要ない
                    RakutenAPI.resultItems.removeFirst()
                    // リストに加える
                    for item in RakutenAPI.resultItems {
                        var resultItemData = ItemData()
                        resultItemData.name = item.name
                        resultItemData.image = item.image
                        resultItemData.folder = newItemFolder()
                        newItems.append(resultItemData)
                    }
                }
                RakutenAPI.resultItems.removeAll()
            }, content: {
                BarcodeReaderView(itemData: $newItems.last!, isItemEdit: false)
            })
            // MARK: - ナビゲーションバー
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("商品登録")
        }
    }
    // MARK: - メソッド
    // ForEachの.onDeleteに渡す関数
    private func rowRemove(offsets: IndexSet) {
        newItems.remove(atOffsets: offsets)
    }
    // 新規作成データのデフォルトフォルダを返す関数
    private func newItemFolder() -> Folder {
        // 在庫フォルダの先頭を返す
        let stockFolders = folders.filter({ $0.isStock == true })
        return stockFolders[0]
    }
    // 空のデータを作成する関数
    private func addNewItem() {
        var newItem = ItemData()
        // フォルダの初期値設定
        newItem.folder = newItemFolder()
        print("\(newItem)")
        // 配列に加える
        newItems.append(newItem)
    }
    // CoreDataに商品データを登録する関数
    private func saveItem() {
        // 作成されたデータの数だけ被管理オブジェクトを作成
        for newItem in newItems {
            // インスタンス作成
            let item = Item(context: context)
            //　入力されたデータを代入
            item.id = newItem.id
            item.name = newItem.name
            item.image = newItem.image
            item.notificationDate = newItem.notificationDate
            item.deadLine = newItem.deadLine
            item.status = newItem.status
            item.isHurry = newItem.isHurry
            item.numberOfItems = newItem.numberOfItems
            item.registrationDate = newItem.registrationDate
            item.folder = newItem.folder
            // 通知日時が設定されている場合
            if let date = item.notificationDate,
               let identifier = item.id?.uuidString {
                    // 通知作成
                    notificationManager.makeNotification(name: item.name!,
                                                         notificationDate: date,
                                                         identifier: identifier)
            }
        }
        do {
            // 保存
            try context.save()
            // アラート表示
            saveAlert.toggle()
            // サウンド再生
            soundPlayer.saveSoundPlay()
        } catch {
            print(error)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
