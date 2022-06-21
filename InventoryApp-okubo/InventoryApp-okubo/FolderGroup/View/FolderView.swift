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
    @State private var isEditing = false
    // フォルダ設定画面の呼び出しフラグ
    @State private var showSheet = false
    // フォルダ設定画面に渡すインデックス番号
    @State private var folderIndex: Int?
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                // 在庫リストのフォルダのみ取得
                let stock = testData.folders.filter({$0.isStock})
                // 在庫リストのフォルダ
                Section {
                    ForEach(stock) { folder in
                        if isEditing {
                            Button(action: {
                                folderIndex = testData.folders.firstIndex(where: {$0.id == folder.id})
                                showSheet.toggle()
                            }, label: {
                                HStack {
                                    Image(systemName: folder.icon)
                                        .foregroundColor(.orange)
                                    Text(folder.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "folder.badge.gearshape")
                                        .foregroundColor(.gray)
                                }
                            })
                        } else {
                            NavigationLink(destination: ItemListView(folder: folder)) {
                                HStack {
                                    Image(systemName: folder.icon)
                                        .foregroundColor(.orange)
                                    Text(folder.name)
                                }
                            }// NavigationLink
                        }
                    }// ForEach
                } header: {
                    Text("在庫リスト")
                }
                // 買い物リストのフォルダ
                let buy = testData.folders.filter({$0.isStock == false})
                Section {
                    ForEach(buy) { folder in
                        if isEditing {
                            Button(action: {
                                folderIndex = testData.folders.firstIndex(where: {$0.id == folder.id})
                                showSheet.toggle()
                            }, label: {
                                HStack {
                                    Image(systemName: folder.icon)
                                        .foregroundColor(.orange)
                                    Text(folder.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "folder.badge.gearshape")
                                        .foregroundColor(.gray)
                                }
                            })
                        } else {
                            NavigationLink(destination: ItemListView(folder: folder)) {
                                HStack {
                                    Image(systemName: folder.icon)
                                        .foregroundColor(.orange)
                                    Text(folder.name)
                                }
                            }// NavigationLink
                        }
                    }// ForEach
                } header: {
                    Text("買い物リスト")
                }
            }// Form
            .sheet(isPresented: $showSheet, content: {
                // 設定画面
                FolderEditView(folderIndex: $folderIndex)
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
                                folderIndex = nil
                                showSheet.toggle()
                            }
                        }
                    }
                })
            }// toolbar
        }// NavigationView
    }// View
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
