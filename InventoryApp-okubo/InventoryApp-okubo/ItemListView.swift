//
//  ItemListView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/09.
//

import SwiftUI

struct ItemListView: View {
    var body: some View {
        Text("フォルダ内の商品リスト")
            .navigationTitle("商品リスト")
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
