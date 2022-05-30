//
//  ItemImageView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/04/15.
//

import SwiftUI
/// 画像データを読み込んで表示するView
struct ItemImageView: View {
    // MARK: - プロパティ
    /// 画像データ
    var imageData: Data?
    // MARK: - View
    var body: some View {
        if let data = imageData {
            // データをUIImage型に変換
            let image = UIImage(data: data)
            // 表示する画像
            Image(uiImage: image!)
                .resizable()
        } else {
            // データがない場合のアイコン表示
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.orange)
        }
    }
}

struct ItemImageView_Previews: PreviewProvider {
    static var previews: some View {
        ItemImageView(imageData: nil)
    }
}
