//
//  RegisterView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/08.
//

import SwiftUI
// 商品登録画面
struct RegisterView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 在庫リストか買い物リストどちらに登録するかの判定
    @State private var isStock = true
    // MARK: - View
    var body: some View {
        VStack {
            Picker("", selection: $isStock) {
                Text("在庫リスト").tag(true)
                Text("買い物リスト").tag(false)
            }
            .pickerStyle(.segmented)
            // 商品データ
            ItemDataView(isStock: $isStock, itemData: $testData.newItem)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("商品登録")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
