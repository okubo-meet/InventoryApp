//
//  RegisterView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/08.
//

import SwiftUI

struct RegisterView: View {
    @State var showingDialog = false
    @State var showBarcodeReader = false
    @State var showImagePicker = false
    @State var showLibrary = false
    var body: some View {
        VStack {
            Text("登録画面")
            Button("画像追加ダイアログ") {
                showingDialog = true
            }
            .confirmationDialog("画像を追加", isPresented: $showingDialog, titleVisibility: .visible) {
                //アクションボタンリスト
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
        }
        .sheet(isPresented: $showBarcodeReader) {
            BarcodeReaderView()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView()
        }
        .sheet(isPresented: $showLibrary) {
            ImageLibraryView()
        }
        .navigationTitle("商品登録")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
