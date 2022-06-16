//
//  FolderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
// フォルダデータを扱う画面　TabViewで扱うView
struct FolderView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 編集モードのフラグ
    @State var isEditing = false
    // フォルダ設定画面の呼び出しフラグ
    @State var showSheet = false
    // フォルダ設定画面に渡すインデックス番号
    private var folderIndex: Int?
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                // 在庫リストのフォルダのみ取得
                let stock = testData.folders.filter({$0.isStock})
                let buy = testData.folders.filter({$0.isStock == false})
                // 在庫リストのフォルダ
                Section {
                    ForEach(stock) { folder in
                        NavigationLink(destination: ItemListView(folder: folder)) {
                            HStack {
                                Image(systemName: folder.icon)
                                    .foregroundColor(.orange)
                                Text(folder.name)
                            }
                        }// NavigationLink
                    }// ForEach
                } header: {
                    Text("在庫リスト")
                }
                // 買い物リストのフォルダ
                Section {
                    ForEach(buy) { folder in
                        NavigationLink(destination: ItemListView(folder: folder)) {
                            HStack {
                                Image(systemName: folder.icon)
                                    .foregroundColor(.orange)
                                Text(folder.name)
                            }
                        }// NavigationLink
                    }// ForEach
                } header: {
                    Text("買い物リスト")
                }
            }// Form
            .sheet(isPresented: $showSheet, content: {
                // 設定画面
                FolderEditView(folder: editFolder())
            })
            .navigationTitle("フォルダ")
            .toolbar {
                // 編集ボタン
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }, label: {
                        if isEditing {
                            Text("完了")
                        } else {
                            Text("編集")
                        }
                    })
                })
                // 新規作成ボタン
                ToolbarItem(placement: .bottomBar, content: {
                    if isEditing {
                        HStack {
                            Spacer()
                            Button("新規フォルダ作成") {
                                // フォルダ設定画面を呼び出す
                                showSheet = true
                            }
                        }
                    }
                })
            }// toolbar
        }// NavigationView
    }// View
    // MARK: - メソッド
    // 設定画面に編集するフォルダを渡す関数
    func editFolder() -> Folder {
        if let folderIndex = folderIndex {
            return testData.folders[folderIndex]
        } else {
            return Folder(name: "", isStock: true, icon: Icon.house.rawValue)
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
