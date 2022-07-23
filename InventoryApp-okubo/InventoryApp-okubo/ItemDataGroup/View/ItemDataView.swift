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
    /// 表示するデータ
    @Binding var itemData: ItemData
    // 在庫か買い物かの判定
    @State private var isStock = true
    // 編集可能状態の切り替えフラグ
    @State private var isEditing = true
    // 新規登録データか登録済みデータかの判定
    var isFolderItem: Bool
    // 画像のサイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 3
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
                // 変更されたとき保存先フォルダも変更する
                if changed {
                    itemData.folder = stockFolders[0]
                } else {
                    // 画面起動時の変更ではフォルダを切り替えない
                    if changed != itemData.folder?.isStock {
                        itemData.folder = buyFolders[0]
                        // 在庫リストから買い物リストに変更したとき通知を無効にする
                        itemData.notificationDate = nil
                    }
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
                            AddImageButton(itemData: $itemData)
                        }
                    }// VStack
                    Spacer()
                }
                // 商品名
                HStack {
                    Text("商品名:")
                    TextField("入力してください（必須）", text: $itemData.name)
                    .disabled(isEditing == false)
                }
                // 期限と通知は在庫リストのみ表示
                if isStock {
                    // 期限
                    HStack {
                        Text("期限:")
                        if itemData.deadLine == nil {
                            // 期限無し
                            Text("無し")
                        } else {
                            DatePicker("", selection: Binding<Date>(get: {itemData.deadLine ?? Date()},
                                                                    set: {itemData.deadLine = $0}),
                                       displayedComponents: .date)
                            .labelsHidden()
                            .disabled(isEditing == false)
                        }
                        Spacer()
                        // 編集可能な場合のみ表示
                        if isEditing {
                            // 期限の有り無しを選択するボタン
                            Image(systemName: deadLineIcon())
                                .foregroundColor(itemData.deadLine == nil ? .orange : .gray)
                                .onTapGesture {
                                    // 期限がnilなら現在の日付を代入し、すでに日付があればnilを代入する
                                    if itemData.deadLine == nil {
                                        itemData.deadLine = Date()
                                    } else {
                                        itemData.deadLine = nil
                                        // 通知の日程もnilにする
                                        itemData.notificationDate = nil
                                    }
                                }
                        }
                    }
                    // 通知の日付
                    HStack {
                        Text("通知:")
                        Text(dateText(date: itemData.notificationDate))
                        // 期限が設定されているときのみ表示
                        if let deadLine = itemData.deadLine {
                            Spacer()
                            Picker("", selection: $itemData.notificationDate) {
                                ForEach(NotificationDate.allCases, id: \.self) { day in
                                    Text(day.rawValue).tag(day.toDate(deadLine: deadLine))
                                }
                            }
                            .pickerStyle(.menu)
                            .disabled(isEditing == false)
                        }
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
        .navigationBarTitleDisplayMode(.inline)
        // ツールバー
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                // 登録済みのデータの場合は編集切り替えボタンを表示する
                if isFolderItem {
                    Button(editButtonText()) {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
            })
        })// toolbar
        // 画面起動時
        .onAppear {
            // 在庫リストかどうかの判定
            if let itemFolder = itemData.folder?.isStock {
                isStock = itemFolder
            }
            print("登録済みデータ: \(isFolderItem)")
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
            return "なし"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
    // 期限がある場合とない場合で違う画像を返す関数
    private func deadLineIcon() -> String {
        if itemData.deadLine == nil {
            return "calendar.badge.plus"
        } else {
            return "xmark.circle.fill"
        }
    }
    // 編集モード切り替えボタンのテキストを返す関数
    private func editButtonText() -> String {
        if isEditing {
            return "完了"
        } else {
            return "編集"
        }
    }
}

struct ItemDataView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDataView(itemData: .constant(ItemData()), isFolderItem: false)
    }
}
