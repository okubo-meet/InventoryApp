//
//  FolderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI

struct FolderView: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink(destination: ItemListView()) {
                    Text("商品リスト")
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
