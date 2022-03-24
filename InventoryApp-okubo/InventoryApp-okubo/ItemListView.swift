//
//  ItemListView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/09.
//

import SwiftUI

struct ItemListView: View {
    //仮のデータ
    @EnvironmentObject var testData: TestData
    //リストから遷移するフラグ
    @State var isActive = false
    //どの遷移先で表示するデータのインデックス番号
    @State var indexNum = 0
    @State var isStock = true
    ///どのカテゴリのリストかを受け取る変数
    var folder: Folder
    var body: some View {
        ZStack {
            VStack {
                List(folderItems(folderName: folder.name)) { item in
                    ListRowView(item: item, isStock: folder.isStock)
                        .onTapGesture {
                            isStock = folder.isStock
                            showItemView(item: item)
                        }
                }// List
                .listStyle(.plain)
            }//VStack
            NavigationLink(destination: ItemDataView(isStock: $isStock, itemData: $testData.items[indexNum]), isActive: $isActive) {
                EmptyView()
            }
            .navigationTitle(folder.name)
        }// ZStack
    }
    //フォルダ名から商品リストを検索して返す関数
    func folderItems(folderName: String) -> [ItemData] {
        let items = testData.items.filter({$0.folder == folderName})
        return items
    }
    //データから配列のインデックス番号を検索し、NavigationLinkを起動する関数
    func showItemView(item: ItemData) {
        if let index = testData.items.firstIndex(where: { $0.id == item.id }) {
            indexNum = index
            print("インデックス番号: \(indexNum)")
            isActive = true
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(folder: TestData().folders[0])
    }
}
