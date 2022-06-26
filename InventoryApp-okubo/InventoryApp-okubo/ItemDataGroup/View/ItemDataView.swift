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
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    /// 在庫か買い物かの判定
    @Binding var isStock: Bool
    /// 表示するデータ
    @Binding var itemData: ItemData
    // 編集可能状態の切り替えフラグ
    @State private var isEditing = true
    // 画像のサイズ
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 3
    // MARK: - View
    var body: some View {
        // TODO: - 各項目は編集可能状態でないときに無効化する
            List {
                HStack {
                    Spacer()
                    VStack {
                        ItemImageView(imageData: itemData.image)
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize, alignment: .center)
                            .background(itemData.image == nil ?
                                        Color.noImage : Color.white) // 画像データの有無で背景色を変える
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
                    Picker("", selection: $itemData.folder) {
                        let folders = testData.folders.filter({$0.isStock == isStock})
                        ForEach(folders) { folder in
                            Text(folder.name).tag(folder.name)
                        }
                    }
                    .pickerStyle(.menu)
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
                // TODO: - 新規登録データか登録済みのデータか判定する
            }
        // TODO: - 登録済みのデータの場合はtoolBarに編集切り替えボタンなどを表示する
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
