//
//  RecentRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/31.
//

import SwiftUI
//「最近の項目」で並べるView　ここからItemListViewに遷移させる予定
struct RecentRowView: View {
    // MARK: - プロパティ
    //仮のデータ
    @EnvironmentObject var testData: TestData
    //画面サイズ
    private let screenWidth = CGFloat(UIScreen.main.bounds.width)
    private let screenHeight = CGFloat(UIScreen.main.bounds.height)
    //カテゴリ名　後で列挙型で作る可能性あり
    var category: String
    
    // MARK: - View
    var body: some View {
        //表示するカテゴリ
        VStack(alignment: .leading) {
            //カテゴリの先頭のデータの画像
            ItemImageView(imageData: testData.items[0].image)
                .scaledToFit()
                .frame(width: screenHeight / 6, height: screenHeight / 6, alignment: .center)
                .background(Color.white)
                .border(Color.black, width: 1)
            //カテゴリ名
            Text(category)
                .font(.body)
            //カテゴリのデータの数
            Text("1")
                .foregroundColor(.gray)
                .font(.callout)
        }// VStack
    }
}

struct RecentRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecentRowView(category: "テスト")
    }
}