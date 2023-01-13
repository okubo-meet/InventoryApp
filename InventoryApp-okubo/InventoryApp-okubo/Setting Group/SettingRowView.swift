//
//  SettingRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/12/16.
//

import SwiftUI
// 設定画面でアプリの状態を表示する行
struct SettingRowView: View {
    // MARK: - プロパティ
    var title: String
    var iconName: String
    var text: String
    // MARK: - View
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(title)
            Spacer()
            Text(text)
                .foregroundColor(.gray)
        }
        .font(.body)
    }
}

struct SettingRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingRowView(title: "タイトル", iconName: "cloud.fill", text: "テキスト")
    }
}
