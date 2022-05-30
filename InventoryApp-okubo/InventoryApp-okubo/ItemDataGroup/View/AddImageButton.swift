//
//  AddImageButton.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/30.
//

import SwiftUI
// カメラをやサンプル画像ライブラリを呼び出すボタン　ItemDataViewで使用
struct AddImageButton: View {
    // MARK: - プロパティ
    // 編集する商品データ
    @Binding var item: ItemData
    // ダイアログ表示トリガー
    @State private var showingDialog = false
    // バーコードリーダー表示トリガー
    @State private var showBarcodeReader = false
    // 撮影カメラ表示トリガー
    @State private var showImagePicker = false
    // サンプル画像リスト表示トリガー
    @State private var showLibrary = false
    // MARK: - View
    var body: some View {
        Button("画像を設定する") {
            showingDialog = true
        }
        .foregroundColor(.orange)
        // ダイアログ
        .confirmationDialog("画像を追加", isPresented: $showingDialog, titleVisibility: .visible) {
            // アクションボタンリスト
            Button("バーコード検索") {
                showBarcodeReader = true
            }
            Button("自分で撮影") {
                showImagePicker = true
            }
            Button("サンプル画像を選択") {
                showLibrary = true
            }
        } message: {
            Text("画像を追加する方法を選択してください")
        }
        .sheet(isPresented: $showBarcodeReader) {
            BarcodeReaderView(item: $item)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(item: $item)
        }
        .sheet(isPresented: $showLibrary) {
            ImageLibraryView()
        }
    }
}

struct AddImageButton_Previews: PreviewProvider {
    static var previews: some View {
        AddImageButton(item: .constant(TestData().items[0]))
    }
}
