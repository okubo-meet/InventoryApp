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
    @ObservedObject var item: Item
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
                Spacer()
                // 商品名
                if let itemName = item.name {
                    Text(itemName)
                        .font(.body)
                        .fontWeight(.semibold)
                }
                Spacer()
                HStack {
                    if isStock {
                        // 在庫リストの表示
                        Text("期限：" + dateText(date: item.deadLine))
                            .font(.callout)
                            .fontWeight(.regular)
                            .foregroundColor(deadLineOver() ? .red : .primary)
                    } else {
                        // 買い物リストの表示
                        Text("登録日：" + dateText(date: item.registrationDate))
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    Spacer()
                }
            }// VStack
            Spacer()
            VStack {
                // 商品の状態
                if isStock {
                    if let itemStatus = item.status {
                        // 在庫リストの表示
                        Text(itemStatus)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(ItemStatus(rawValue: itemStatus)?.toStatusColor())
                            .multilineTextAlignment(.trailing)
                    }
                } else {
                    // 買い物リストの表示
                    Text(Urgency(isHurry: item.isHurry).rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Urgency(isHurry: item.isHurry).color())
                }
                Spacer()
                HStack {
                    // 個数
                    Text("×\(item.numberOfItems)")
                        .font(.body)
                        .fontWeight(.medium)
                    // 画面遷移を表すアイコン
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }// HStack
                .padding(.leading)
                Spacer()
                Spacer()
            }// VStack
        }// HStack
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
    // 期限表示の色を切り替えるBoolを返す関数
    private func deadLineOver() -> Bool {
        // 期限が現在もしくは過ぎている場合trueを返す
        if let deadLine = item.deadLine {
            if deadLine <= Date() {
                return true
            }
        }
        return false
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(item: Item(), isStock: true)
    }
}
