//
//  ItemDataView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/22.
//

import SwiftUI
// データの詳細を表示するView
struct ItemDataView: View {
    // MARK: - プロパティ
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // 在庫リストのフォルダのみ取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: false)],
                  predicate: NSPredicate(format: "isStock == %@", NSNumber(value: true)),
                  animation: .default)
    private var stockFolders: FetchedResults<Folder>
    // 買い物リストのフォルダのみ取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.id, ascending: false)],
                  predicate: NSPredicate(format: "isStock == %@", NSNumber(value: false)),
                  animation: .default)
    private var buyFolders: FetchedResults<Folder>
    // 登録された商品データを取得
    @FetchRequest(entity: Item.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.registrationDate, ascending: true)])
    private var items: FetchedResults<Item>
    // 表示するデータ
    @Binding var itemData: ItemData
    // 商品名入力欄で扱う文字列
    @State private var itemName = ""
    // 在庫か買い物かの判定
    @State private var isStock = true
    // 編集可能状態の切り替えフラグ
    @State private var isEditing = true
    // データ編集アラートのフラグ
    @State private var editAlert = false
    // 保存完了アラートのフラグ
    @State private var savedAlert = false
    // TextFieldのフォーカスを制御する変数
    @FocusState private var focusState: Bool
    // 新規登録データか登録済みデータかの判定
    var isFolderItem: Bool
    // 画像のサイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 3
    //　効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // MARK: - View
    var body: some View {
        VStack {
            Picker("", selection: $isStock) {
                Text("在庫リスト").tag(true)
                Text("買い物リスト").tag(false)
            }
            .pickerStyle(.segmented)
            .disabled(isEditing == false)
            .onChange(of: isStock, perform: { changed in
                // 画面起動時の変更では値をを切り替えない
                if changed != itemData.folder?.isStock {
                    // デフォルトの値をセットする
                    let defaultData = defaultValue(changed: changed)
                    itemData.folder = defaultData.folder
                    itemData.isHurry = defaultData.isHurry
                    itemData.deadLine = defaultData.deadLine
                    itemData.notificationDate = defaultData.notificationDate
                    itemData.status = defaultData.status
                }
            })
            List {
                // 画像
                HStack {
                    Spacer()
                    VStack {
                        ItemImageView(imageData: itemData.image)
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize, alignment: .center)
                            .background(itemData.image == nil ?
                                        Color.noImage : Color.white)
                            .border(Color.orange, width: 1)
                        // 編集可能な場合のみ表示
                        if isEditing {
                            // 画像追加ボタン
                            AddImageButton(itemData: $itemData, itemName: $itemName)
                        }
                    }// VStack
                    Spacer()
                }
                // 商品名
                HStack {
                    Text("商品名:")
                    TextField("入力してください（必須）", text: $itemName)
                        .disabled(isEditing == false)
                        .focused($focusState)
                        .onChange(of: itemName, perform: { value in
                            itemData.name = value
                        })
                }
                // 期限と通知は在庫リストのみ表示
                if isStock {
                    // 期限
                    DatePickerRow(itemData: $itemData, isEditing: $isEditing,
                                  isDeadLine: true)
                    // 期限が設定されているときのみ表示
                    if itemData.deadLine != nil {
                        // 通知の日付
                        DatePickerRow(itemData: $itemData, isEditing: $isEditing,
                                      isDeadLine: false)
                    }
                }
                // 個数
                HStack {
                    Text("個数:")
                    Stepper(value: $itemData.numberOfItems, in: 0...99) {
                        Text("\(itemData.numberOfItems)個")
                    }
                    .disabled(isEditing == false)
                }
                // 状態
                HStack {
                    if isStock {
                        // 在庫リスト
                        Text("状態: ")
                        // 編集可能状態に応じて変化
                        if isEditing {
                            Picker("", selection: $itemData.status) {
                                ForEach(ItemStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        } else {
                            Text(itemData.status)
                        }
                    } else {
                        // 買い物リスト
                        Text("緊急性:")
                        // 編集可能状態に応じて変化
                        if isEditing {
                            Picker("", selection: $itemData.isHurry) {
                                Text(Urgency.hurry.rawValue).tag(true)
                                Text(Urgency.normal.rawValue).tag(false)
                            }
                            .pickerStyle(.menu)
                        } else {
                            Text(Urgency(isHurry: itemData.isHurry).rawValue)
                        }
                    }
                }
                // 保存先はCoreDataに登録されているフォルダから選択できるようにする
                HStack {
                    Text("フォルダ選択:")
                    // 編集可能状態に応じて変化
                    if isEditing {
                        Picker("", selection: Binding<Folder>(get: {itemData.folder ?? stockFolders[0]},
                                                              set: {itemData.folder = $0})) {
                            if isStock {
                                // 在庫リスト
                                ForEach(stockFolders) { folder in
                                    Label(folder.name!, systemImage: folder.icon!).tag(folder)
                                }
                            } else {
                                // 買い物リスト
                                ForEach(buyFolders) { folder in
                                    Label(folder.name!, systemImage: folder.icon!).tag(folder)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Text((itemData.folder?.name!)!)
                    }
                }
                // 登録日
                HStack {
                    Text("登録日:")
                    Text(dateText(date: itemData.registrationDate))
                }
            }// List
            .listStyle(.plain)
        }// VStack
        // 編集終了アラート
        .alert("データに変更があります", isPresented: $editAlert, actions: {
            Button("キャンセル") {
                // idが一致しているデータのインデックス番号を取得
                if let index = items.firstIndex(where: {$0.id == itemData.id}) {
                    // 変更されたデータを元に戻す
                    isStock = items[index].folder!.isStock
                    itemData = changeCancel(item: items[index])
                    itemName = itemData.name
                }
            }
            Button("保存") {
                // idが一致しているデータのインデックス番号を取得
                if let index = items.firstIndex(where: {$0.id == itemData.id}) {
                    // 変更をCoreDataに保存する
                    saveItem(item: items[index], itemData: itemData)
                    // 登録日の表示を更新
                    itemData.registrationDate = items[index].registrationDate!
                    // 保存完了アラート表示
                    savedAlert.toggle()
                    // 効果音再生
                    soundPlayer.saveSoundPlay()
                }
            }
        }, message: {
            Text("この状態で保存しますか？")
        })
        // 保存完了アラート
        .alert("変更を保存しました", isPresented: $savedAlert, actions: {}, message: {
            Text("登録日も更新されました。")
        })
        // タイトル
        .navigationBarTitleDisplayMode(.inline)
        // ツールバー
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                // 登録済みのデータの場合は編集切り替えボタンを表示する
                if isFolderItem {
                    Button(editButtonText()) {
                        // 編集を終了するときアラート表示
                        if isEditing {
                            if let index = items.firstIndex(where: {$0.id == itemData.id}) {
                                // 変更がある場合のみアラートを表示
                                if isDataChange(item: items[index], itemData: itemData) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        editAlert.toggle()
                                    }
                                }
                            }
                        }
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    .disabled(itemName == "") // 商品名が空欄の場合は保存できない
                }
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
        // 画面起動時
        .onAppear {
            // TextFieldに商品名を代入
            itemName = itemData.name
            // 在庫リストかどうかの判定
            if let folderType = itemData.folder?.isStock {
                isStock = folderType
            }
            if isFolderItem {
                // 登録済みのデータなら編集不可状態にする
                isEditing = false
            }
        }
    }
    // MARK: - メソッド
    // 日付フォーマットの関数
    private func dateText(date: Date?) -> String {
        guard let date = date else {
            return "無し"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
    // 在庫データ買い物データを切り替えた時の関数
    private func defaultValue(changed: Bool) -> ItemData {
        // 初期値
        var value = ItemData()
        // 変更されたとき保存先フォルダを変更する
        if changed {
            // 在庫のフォルダを代入
            value.folder = stockFolders[0]
        } else {
            // 買い物のフォルダを代入
            value.folder = buyFolders[0]
        }
        // 既に登録されているデータかつ
        if let index = items.firstIndex(where: {$0.id == itemData.id}) {
            let savedData = changeCancel(item: items[index])
            // 元のタイプに戻った時
            if savedData.folder?.isStock == changed {
                // 登録されている値を代入
                value = savedData
            }
        }
        return value
    }
    // 編集モード切り替えボタンのテキストを返す関数
    private func editButtonText() -> String {
        if isEditing {
            return "完了"
        } else {
            return "編集"
        }
    }
    // データが変更されているか判定する関数
    private func isDataChange(item: Item, itemData: ItemData) -> Bool {
        // 登録されたデータと一致しているか判定
        if item.name == itemData.name
            && item.image == itemData.image
            && item.notificationDate == itemData.notificationDate
            && item.deadLine == itemData.deadLine
            && item.status == itemData.status
            && item.isHurry == itemData.isHurry
            && item.numberOfItems == itemData.numberOfItems
            && item.folder == itemData.folder {
            // 変更無し
            return false
        }
        // 変更あり
        return true
    }
    // データの変更を保存する関数
    private func saveItem(item: Item, itemData: ItemData) {
        // 上書き
        item.name = itemData.name
        item.image = itemData.image
        item.notificationDate = itemData.notificationDate
        item.deadLine = itemData.deadLine
        item.status = itemData.status
        item.isHurry = itemData.isHurry
        item.numberOfItems = itemData.numberOfItems
        item.folder = itemData.folder
        // 登録日も更新
        item.registrationDate = Date()
        // ローカル通知の識別ID
        if let identifier = item.id?.uuidString {
            // 通知日に応じて通知を編集
            if item.notificationDate == nil {
                // 通知削除
                notificationManager.removeNotification(identifier: identifier)
            } else {
                // 通知作成/上書き
                notificationManager.makeNotification(name: item.name!,
                                                     notificationDate: item.notificationDate!,
                                                     identifier: identifier)
            }
        }
        // 保存
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    // データの変更を破棄する関数
    private func changeCancel(item: Item) -> ItemData {
        var returnData = ItemData()
        // 変更前の状態に戻す（登録日は変更できないので割愛）
        returnData.id = item.id!
        returnData.name = item.name!
        returnData.image = item.image
        returnData.notificationDate = item.notificationDate
        returnData.deadLine = item.deadLine
        returnData.status = item.status!
        returnData.isHurry = item.isHurry
        returnData.numberOfItems = item.numberOfItems
        returnData.folder = item.folder
        return returnData
    }
}

struct ItemDataView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDataView(itemData: .constant(ItemData()), isFolderItem: false)
    }
}
