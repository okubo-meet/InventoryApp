//
//  FolderRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/08.
//

import SwiftUI
// フォルダ画面の行
struct FolderRowView: View {
    // MARK: - プロパティ
    // 編集モードのフラグ
    @Binding var isEditing: Bool
    // フォルダ設定画面の呼び出しフラグ
    @Binding var showSheet: Bool
    // 選択したフォルダのID
    @Binding var folderID: UUID?
    // 表示するフォルダ
    var folder: Folder
    // MARK: - View
    var body: some View {
        if isEditing {
            Button(action: {
                // 設定画面呼び出し
                folderID = folder.id
                showSheet.toggle()
            }, label: {
                HStack {
                    if let icon = folder.icon {
                        Image(systemName: icon)
                            .foregroundColor(.orange)
                    }
                    if let name = folder.name {
                        Text(name)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "folder.badge.gearshape")
                        .foregroundColor(.gray)
                }
            })
        } else {
            NavigationLink(destination: ItemListView(folder: folder)) {
                HStack {
                    if let icon = folder.icon {
                        Image(systemName: icon)
                            .foregroundColor(.orange)
                    }
                    if let name = folder.name {
                        Text(name)
                            .foregroundColor(.primary)
                    }
                }
            }// NavigationLink
        }
    }// View
}

struct FolderRowView_Previews: PreviewProvider {
    static var previews: some View {
        FolderRowView(isEditing: .constant(false), showSheet: .constant(false),
                      folderID: .constant(nil), folder: Folder())
    }
}
