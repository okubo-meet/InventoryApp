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
    // リストに表示するデータの配列
    @State private var listItems: [Item] = []
    // 遷移先で表示するデータのインデックス番号
    @State private var indexNum = 0
    // リストから遷移するフラグ
    @State private var isPresented = false
    // 遷移先に渡す商品データ
    @State private var selectItemData = ItemData()
    // 通知を扱うクラスのインスタンス
    private let notificationManager = NotificationManager()
    // 検索結果の配列
    @State private var searchText = ""
    // フォルダ内の商品データの配列
    private var folderItems: [Item] {
        var sortedItems: [Item] = []
        // NSSet? を [Item]に変換
        if let setItems = folder.items as? Set<Item> {
            // 在庫データの場合
            if folder.isStock {
                // 期限で降順にソート（nilは後ろ）
                sortedItems = setItems.sorted { first, second in
                    if let firstDate = first.deadLine {
                        if second.deadLine == nil {
                            return true
                        } else if second.deadLine! > firstDate {
                            return true
                        } else if second.deadLine! < firstDate {
                            return false
                        }
                    }
                    return false
                }
            } else {
                // 緊急性の高いものから並べる
                sortedItems = setItems.sorted { first, second in
                    // 緊急性が同じ場合は日付順
                    if first.isHurry == second.isHurry {
                        if first.registrationDate! < second.registrationDate! {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        // 緊急性の高いものから並べる
                        if first.isHurry {
                            return true
                        } else {
                            return false
                        }
                    }
                }
            }
        }
        return sortedItems
    }
    // MARK: - View
    var body: some View {
        ZStack {
            List {
                ForEach(searchResults, id: \.self) { item in
                    // 同じフォルダに登録されたデータリスト
                    ListRowView(item: item, isStock: folder.isStock)
                        .onTapGesture {
                            // 遷移先で表示するデータを代入
                            selectItemData = setItemData(item: item)
                            // 画面遷移
                            isPresented = true
                        }
                }// ForEach
                .onDelete(perform: removeItem)
            }// List
            .listStyle(.plain)
            // 画面起動時
            .onAppear {
                // リストにソートしたデータを代入
                listItems = folderItems
            }
            .navigationTitle(navigationTitleString())
            .navigationBarTitleDisplayMode(.large)
            // 遷移先
            .navigationDestination(isPresented: $isPresented) {
                ItemDataView(itemData: $selectItemData, isFolderItem: true)
            }
            // 検索バー
            .searchable(text: $searchText)
            
            if listItems.isEmpty {
                VStack {
                    Spacer()
                    Text("データがありません")
                        .font(.title)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
    }
    
    var searchResults: [Item] {
        if searchText.isEmpty {
            return listItems
        } else {
            return listItems.filter { $0.name?.contains(searchText) ?? false }
        }
    }
    
    // MARK: - メソッド
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
            let removeItem = listItems[index]
            print("削除するデータ：\(String(describing: removeItem.name))")
            // ローカル通知の識別ID
            if let identifier = removeItem.id?.uuidString {
                // 通知を削除
                notificationManager.removeNotification(identifier: identifier)
            }
            // リストから削除
            listItems.remove(at: index)
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
