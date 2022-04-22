//
//  FolderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
//フォルダデータを扱う画面　TabViewで扱うView
struct FolderView: View {
    // MARK: - プロパティ
    //仮のデータ
    @EnvironmentObject var testData: TestData
    
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                //在庫リストのフォルダのみ取得
                let stock = testData.folders.filter({$0.isStock})
                let buy = testData.folders.filter({$0.isStock == false})
                //在庫リストのフォルダ
                Section {
                    ForEach(stock) { folder in
                        NavigationLink(destination: ItemListView(folder: folder)) {
                            HStack {
                                Image(systemName: folder.icon!)
                                    .foregroundColor(.orange)
                                Text(folder.name)
                            }
                        }// NavigationLink
                    }// ForEach
                } header: {
                    Text("在庫リスト")
                }
                //買い物リストのフォルダ
                Section {
                    ForEach(buy) { folder in
                        NavigationLink(destination: ItemListView(folder: folder)) {
                            HStack {
                                Text(folder.name)
                            }
                        }// NavigationLink
                    }// ForEach
                } header: {
                    Text("買い物リスト")
                }
            }// Form
            .navigationTitle("フォルダ")
        }// NavigationView
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
