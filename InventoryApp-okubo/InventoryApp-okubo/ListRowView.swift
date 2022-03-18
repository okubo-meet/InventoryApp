//
//  ListRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/18.
//

import SwiftUI

struct ListRowView: View {
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 4
    private let rowHeight = CGFloat(UIScreen.main.bounds.height) / 8
    //商品データ
    var item: ItemData
    //在庫か買い物か
    var isStock: Bool
    var body: some View {
        if isStock {
            //在庫リストの表示
            HStack {
                //画像
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                VStack {
                    //商品名
                    Text(item.namme)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,alignment: .leading)
                    //賞味期限
                    Text("期限：" + deadLineText(date: item.deadLine))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }// VStack
                Spacer()
                VStack {
                    //状態
                    Text(item.status)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                        .foregroundColor(ItemStatus(rawValue: item.status)?.toStatusColor())
                    //個数
                    Text("×\(item.numberOfItems)")
                }// VStack
                .padding(.trailing)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: rowHeight, alignment: .leading)
        } else {
            //買い物リストの表示
        }
    }
    //日付フォーマットの関数
    func deadLineText(date: Date?) -> String {
        guard let date = date else {
            return "なし"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(item: TestData().items[0], isStock: true)
    }
}
