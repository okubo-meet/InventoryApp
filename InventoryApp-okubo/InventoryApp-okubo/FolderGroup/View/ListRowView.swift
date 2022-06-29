//
//  ListRowView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/18.
//

import SwiftUI
// ItemListViewでリスト表示するView
struct ListRowView: View {
    // MARK: - プロパティ
    // 商品データ
    var item: ItemData
    // 在庫か買い物か
    var isStock: Bool
    // 画像サイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 4
    // 行の高さ
    private let rowHeight = CGFloat(UIScreen.main.bounds.height) / 8
    // MARK: - View
    var body: some View {
        HStack {
            // 画像
            ItemImageView(imageData: item.image)
                .scaledToFit()
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .background(Color.white)
                .border(Color.gray, width: 1)
            VStack {
                // 商品名
                Text(item.name)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,
                           alignment: .leading)
                if isStock {
                    // 在庫リストの表示
                    Text("期限：" + dateText(date: item.deadLine))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                } else {
                    // 買い物リストの表示
                    Text("登録日：" + dateText(date: item.registrationDate))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }// VStack
            Spacer()
            VStack {
                if isStock {
                    // 在庫リストの表示
                    Text(item.status)
                        .foregroundColor(ItemStatus(rawValue: item.status)?.toStatusColor())
                } else {
                    // 買い物リストの表示
                    if item.isHurry {
                        Text("緊急")
                            .foregroundColor(.red)
                    } else {
                        Text("通常")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                // 個数
                Text("×\(item.numberOfItems)")
                Spacer()
                Spacer()
            }// VStack
            .padding(.trailing)
        }// HStack
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: rowHeight, alignment: .leading)
        .contentShape(Rectangle())
    }
    // MARK: - メソッド
    // 日付フォーマットの関数
    private func dateText(date: Date?) -> String {
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
