//
//  ItemDataView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/22.
//

import SwiftUI
// データの詳細を表示するView
struct ItemDataView: View {
    // MARK: - プロパティ
    /// 在庫か買い物かの判定
    @Binding var isStock: Bool
    /// 表示するデータ
    @Binding var itemData: ItemData
    // 画像のサイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 3
    // MARK: - View
    var body: some View {
            List {
                HStack {
                    Spacer()
                    VStack {
                        ItemImageView(imageData: itemData.image)
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize, alignment: .center)
                            .background(Color.imageBackground)
                            .border(Color.orange, width: 1)
                        // 画像追加ボタン
                        AddImageButton(item: $itemData)
                    }// VStack
                    Spacer()
                }
                HStack {
                    Text("商品名:")
                    TextField("入力してください（必須）", text: $itemData.name)
                }
                // 期限と通知は在庫リストのみ表示
                if isStock {
                    HStack {
                        Text("期限:")
                        if itemData.deadLine == nil {
                            // 期限無し
                            Text("無し")
                        } else {
                            DatePicker("", selection: Binding<Date>(get: {itemData.deadLine ?? Date()},
                                                                    set: {itemData.deadLine = $0}),
                                       displayedComponents: .date)
                                .labelsHidden()
                        }
                        Spacer()
                        // 期限の有り無しを選択するボタン
                        Image(systemName: deadLineIcon())
                            .foregroundColor(itemData.deadLine == nil ? .orange : .gray)
                            .onTapGesture {
                                // 期限がnilなら現在の日付を代入し、すでに日付があればnilを代入する
                                if itemData.deadLine == nil {
                                    itemData.deadLine = Date()
                                } else {
                                    itemData.deadLine = nil
                                }
                            }
                    }
                    // 期限の何日前か計算して表示する
                    HStack {
                        Text("通知:")
                        Text(dateText(date: itemData.notificationDate))
                    }
                }
                HStack {
                    Text("個数:")
                    Stepper(value: $itemData.numberOfItems, in: 0...99) {
                        Text("\(itemData.numberOfItems)個")
                    }
                }
                // Pickerのデザインを検討
                HStack {
                    if isStock {
                        // 在庫リスト
                        Text("状態: ")
                        Picker("", selection: $itemData.status) {
                            ForEach(ItemStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        // 買い物リスト
                        Text("緊急性:")
                        Picker("", selection: $itemData.isHurry) {
                            Text("通常").tag(false)
                            Text("緊急").tag(true)
                        }
                        .pickerStyle(.menu)
                    }
                }
                // 保存先はCoreDataに登録されているフォルダから選択できるようにする
                HStack {
                    Text("保存先:")
                    Text(itemData.folder)
                }
                // 登録日は編集できない
                HStack {
                    Text("登録日:")
                    Text(dateText(date: itemData.registrationDate))
                }
            }
            .listStyle(.plain)
            .onAppear {
                print("データ：　\(itemData)")
            }
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
    // 期限がある場合とない場合で違う画像を返す関数
    private func deadLineIcon() -> String {
        if itemData.deadLine == nil {
            return "calendar.badge.plus"
        } else {
            return "xmark.circle.fill"
        }
    }
}

struct ItemDataView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDataView(isStock: .constant(true), itemData: .constant(TestData().items[0]))
    }
}
