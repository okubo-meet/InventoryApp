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
    // 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    // 在庫リストのフォルダのみ取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
                  predicate: NSPredicate(format: "isStock == %@", NSNumber(value: true)),
                  animation: .default) private var stockFolders: FetchedResults<Folder>
    // 買い物リストのフォルダのみ取得
    @FetchRequest(entity: Folder.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
                  predicate: NSPredicate(format: "isStock == %@", NSNumber(value: false)),
                  animation: .default) private var buyFolders: FetchedResults<Folder>
    // 編集モードのフラグ
    @State private var isEditing = false
    // フォルダ設定画面の呼び出しフラグ
    @State var showSheet = false
    // 選択したフォルダのID
    @State var folderID: UUID?
    // MARK: - View
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // 在庫リストのフォルダ
                    Section {
                        ForEach(stockFolders) { folder in
                            FolderRowView(isEditing: $isEditing, showSheet: $showSheet,
                                          folderID: $folderID, folder: folder)
                        }// ForEach
                    } header: {
                        Text("在庫リスト")
                    }
                    // 買い物リストのフォルダ
                    Section {
                        ForEach(buyFolders) { folder in
                            FolderRowView(isEditing: $isEditing, showSheet: $showSheet,
                                          folderID: $folderID, folder: folder)
                        }// ForEach
                    } header: {
                        Text("買い物リスト")
                    }
                }// Form
                // フォルダが無い場合の表示
                if stockFolders.isEmpty && buyFolders.isEmpty {
                    NoFolderView()
                }
            }
            .sheet(isPresented: $showSheet, content: {
                // 設定画面
                FolderEditView(folderID: $folderID)
            })
            .navigationTitle(titleText())
            .navigationBarTitleDisplayMode(.large)
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
                    .disabled(stockFolders.isEmpty && buyFolders.isEmpty)
                })
                // 新規作成ボタン
                ToolbarItemGroup(placement: .bottomBar, content: {
                    if isEditing {
                        Spacer()
                        Button("新規フォルダ作成") {
                            // フォルダ設定画面を呼び出す
                            folderID = nil
                            showSheet.toggle()
                        }
                        .font(.headline)
                    }
                })
            }// toolbar
        }// NavigationStack
    }
    // MARK: - メソッド
    // navigationTitleの文字列を返す関数
    private func titleText() -> String {
        if isEditing {
            return "編集中"
        } else {
            return "フォルダ"
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
