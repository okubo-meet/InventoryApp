//
//  ListRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/18.
//

import SwiftUI
//ItemListViewでリスト表示するView
struct ListRowView: View {
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 4
    private let rowHeight = CGFloat(UIScreen.main.bounds.height) / 8
    //商品データ
    var item: ItemData
    //在庫か買い物か
    var isStock: Bool
    var body: some View {
        HStack {
            //画像
            Image(uiImage: item.image)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize, alignment: .center)
            VStack {
                //商品名
                Text(item.name)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,alignment: .leading)
                if isStock {
                    //在庫リストの表示
                    Text("期限：" + dateText(date: item.deadLine))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                } else {
                    //買い物リストの表示
                    Text("登録日：" + dateText(date: item.registrationDate))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }// VStack
            Spacer()
            VStack {
                if isStock {
                    //在庫リストの表示
                    Text(item.status)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                        .foregroundColor(ItemStatus(rawValue: item.status)?.toStatusColor())
                } else {
                    //買い物リストの表示
                    if item.isHurry {
                        Text("緊急")
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                            .foregroundColor(.red)
                    } else {
                        Text("通常")
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                            .foregroundColor(.blue)
                    }
                }
                //個数
                Text("×\(item.numberOfItems)")
            }// VStack
            .padding(.trailing)
        }// HStack
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: rowHeight, alignment: .leading)
    }
    //日付フォーマットの関数
    func dateText(date: Date?) -> String {
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
