//
//  FolderRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/22.
//

import SwiftUI
// フォルダ画面の行
struct FolderRowView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 編集モードのフラグ
    @Binding var isEditing: Bool
    // フォルダ設定画面の呼び出しフラグ
    @Binding var showSheet: Bool
    // フォルダ設定画面に渡すインデックス番号
    @Binding var folderIndex: Int?
    // 表示するフォルダ
    var folder: Folder
    // MARK: - View
    var body: some View {
        if isEditing {
            Button(action: {
                // 設定画面呼び出し
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
    }
}

struct FolderRowView_Previews: PreviewProvider {
    static var previews: some View {
        FolderRowView(isEditing: .constant(false), showSheet: .constant(false),
                      folderIndex: .constant(nil), folder: TestData().folders[0])
    }
}
