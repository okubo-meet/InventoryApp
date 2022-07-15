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
    @State var showSheet = false
    // フォルダ設定画面に渡すインデックス番号
    @State var folderIndex: Int?
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                // 在庫リストのフォルダのみ取得
                let stock = testData.folders.filter({$0.isStock})
                // 在庫リストのフォルダ
                Section {
                    ForEach(stock) { folder in
                        FolderRowView(isEditing: $isEditing, showSheet: $showSheet,
                                      folderIndex: $folderIndex, folder: folder)
                    }// ForEach
                } header: {
                    Text("在庫リスト")
                }
                // 買い物リストのフォルダのみ取得
                let buy = testData.folders.filter({$0.isStock == false})
                // 買い物リストのフォルダ
                Section {
                    ForEach(buy) { folder in
                        FolderRowView(isEditing: $isEditing, showSheet: $showSheet,
                                      folderIndex: $folderIndex, folder: folder)
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
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
