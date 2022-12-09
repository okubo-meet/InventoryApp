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
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // どのカテゴリのリストかを受け取る変数
    @ObservedObject var folder: Folder
    // 遷移先で表示するデータのインデックス番号
    @State private var indexNum = 0
    // リストから遷移するフラグ
    @State private var isActive = false
    // 遷移先に渡す商品データ
    @State private var selectItemData = ItemData()
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // MARK: - View
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(folderItems(items: folder.items)) { item in
                        HStack {
                            // 同じフォルダに登録されたデータリスト
                            ListRowView(item: item, isStock: folder.isStock)
                                .onTapGesture {
                                    // 遷移先で表示するデータを代入
                                    selectItemData = setItemData(item: item)
                                    // 画面遷移
                                    isActive = true
                                }
                            // 画面遷移を表すアイコン
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }// HStack
                    }// ForEach
                    .onDelete(perform: removeItem)
                }// List
                .listStyle(.plain)
            }// VStack
            // 商品データが無い場合の表示
            if folderItems(items: folder.items).isEmpty {
                VStack {
                    Spacer()
                    Text("データがありません")
                        .font(.title)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                // 商品データがある場合のみリンクを生成
                NavigationLink(destination: ItemDataView(itemData: $selectItemData,
                                                         isFolderItem: true), isActive: $isActive) {
                    EmptyView()
                }
            }
        }// ZStack
        .navigationTitle(navigationTitleString())
        .navigationBarTitleDisplayMode(.inline)
    }
    // MARK: - メソッド
    // フォルダ名から商品リストを検索して返す関数
    private func folderItems(items: NSSet?) -> [Item] {
        // NSSet? を [Item]に変換
        if let setItems = items as? Set<Item> {
            // 日付でソートした配列を返す
            return setItems.sorted(by: {$0.registrationDate! < $1.registrationDate!})
        } else {
            return []
        }
    }
    // Itemの値をItemDataに変換して返す関数
    private func setItemData(item: Item) -> ItemData {
        var data = ItemData()
        data.id = item.id!
        data.name = item.name!
        data.image = item.image
        data.notificationDate = item.notificationDate
        data.deadLine = item.deadLine
        data.status = item.status!
        data.isHurry = item.isHurry
        data.numberOfItems = item.numberOfItems
        data.registrationDate = item.registrationDate!
        data.folder = item.folder
        return data
    }
    // データを削除する関数(ForEachの.onDeleteに渡す)
    private func removeItem(offsets: IndexSet) {
        // IndexSetからIndex番号を取得
        for index in offsets {
            // 削除するデータ
            let removeItem = folderItems(items: folder.items)[index]
            print("削除するデータ：\(String(describing: removeItem.name))")
            // ローカル通知の識別ID
            if let identifier = removeItem.id?.uuidString {
                // 通知を削除
                notificationManager.removeNotification(identifier: identifier)
            }
            // データを削除する
            context.delete(removeItem)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    // navigationTitleに表示する文字列を返す関数
    private func navigationTitleString() -> String {
        if let name = folder.name {
            return name
        } else {
            return ""
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(folder: Folder())
    }
}
