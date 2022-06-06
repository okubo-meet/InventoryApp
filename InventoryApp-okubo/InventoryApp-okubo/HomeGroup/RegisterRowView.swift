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
                if itemData.name == "" {
                    // 商品名に入力がないとき
                    Text("商品名がありません")
                } else {
                    // 商品名
                    Text(itemData.name)
                        .fontWeight(.bold)
                }
                Text("タップして詳細設定")
                    .font(.caption)
            }
            Spacer()
            // 個数
            Text("×\(itemData.numberOfItems)")
        }
    }
    // MARK: - メソッド
}

struct RegisterRowView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterRowView(itemData: TestData().items[0])
    }
}
