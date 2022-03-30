//
//  RegisterView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/08.
//

import SwiftUI

struct RegisterView: View {
    //仮のデータ
    @EnvironmentObject var testData: TestData
    @State var isStock = true
    @State var showingDialog = false
    @State var showBarcodeReader = false
    @State var showImagePicker = false
    @State var showLibrary = false
    var body: some View {
        VStack {
            Picker("", selection: $isStock) {
                Text("在庫リスト").tag(true)
                Text("買い物リスト").tag(false)
            }
            .pickerStyle(.segmented)
            //商品データ
            ItemDataView(isStock: $isStock, itemData: $testData.items[0])
        }
        .navigationTitle("商品登録")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
