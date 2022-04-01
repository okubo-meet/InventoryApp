//
//  RecentItemsView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
//「最近の項目」の全て表示で遷移してくる画面
struct RecentItemsView: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                RecentRowView(category: "賞味期限通知")
                RecentRowView(category: "買い物リスト")
                RecentRowView(category: "今日")
            }
        }
        .navigationTitle("最近の項目")
    }
}

struct RecentItemsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentItemsView()
    }
}
