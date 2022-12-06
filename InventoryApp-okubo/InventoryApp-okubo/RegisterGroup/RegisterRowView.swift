//
//  RegisterRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/03.
//

import SwiftUI
// 登録する商品リストの行
struct RegisterRowView: View {
    // MARK: - プロパティ
    var itemData: ItemData
    // 画像サイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 4
    // MARK: - View
    var body: some View {
        HStack {
            // 画像
            ItemImageView(imageData: itemData.image)
                .scaledToFit()
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .background(itemData.image == nil ?
                            Color.noImage : Color.white)
                .border(Color.gray, width: 1)
            VStack {
                Spacer()
                Text(itemNameText())
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Text("登録先：" + folderText())
                        .font(.callout)
                        .fontWeight(.medium)
                        .padding(.leading)
                    Spacer()
                }// HStack
            }// VStack
            Spacer()
            // 個数
            Text("×\(itemData.numberOfItems)")
                .font(.body)
                .fontWeight(.medium)
        }
    }
    // MARK: - メソッド
    // 商品名の有無を判定して文字列を返す関数
    private func itemNameText() -> String {
        if itemData.name == "" {
            return "商品名がありません"
        } else {
            return itemData.name
        }
    }
    // フォルダ名を返す関数
    private func folderText() -> String {
        if let folderName = itemData.folder?.name {
            return folderName
        } else {
            return "なし"
        }
    }
}

struct RegisterRowView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterRowView(itemData: ItemData())
    }
}
