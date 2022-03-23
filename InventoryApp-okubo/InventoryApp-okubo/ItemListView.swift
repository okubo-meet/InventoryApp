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
    ///どのカテゴリのリストかを受け取る変数
    var folder: Folder
    var body: some View {
        VStack {
            List(folderItems(folderName: folder.name)) { item in
                ListRowView(item: item, isStock: folder.isStock)
            }// List
            .listStyle(.plain)
            .navigationTitle(folder.name)
        }//VStack
    }
    //フォルダ名から商品リストを検索して返す関数
    func folderItems(folderName: String) -> [ItemData] {
        let items = testData.items.filter({$0.folder == folderName})
        return items
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(folder: TestData().folders[0])
    }
}
