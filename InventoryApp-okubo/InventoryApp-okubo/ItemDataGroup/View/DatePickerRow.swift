//
//  DatePickerRow.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/08/18.
//

import SwiftUI
// 期限と通知日時を設定するDatePicker
struct DatePickerRow: View {
    // MARK: - プロパティ
    // 編集するデータ
    @Binding var itemData: ItemData
    // 編集モードのフラグ
    @Binding var isEditing: Bool
    // 期限か通知日時かの判定
    var isDeadLine: Bool
    // MARK: - View
    var body: some View {
        HStack {
            // タイトル
            Text(rowTitle())
            if editDate() == nil {
                // 期限無し
                Text("無し")
            } else {
                if isDeadLine {
                    // 期限設定のDatePicker（日付のみ）
                    DatePicker("", selection: Binding<Date>(get: {itemData.deadLine ?? defaultDate()},
                                                            set: {itemData.deadLine = $0}),
                               displayedComponents: .date)
                    .labelsHidden()
                    .disabled(isEditing == false)
                } else {
                    // 通知設定のDatePicker（日付 + 時刻）
                    DatePicker("", selection: Binding<Date>(get: {itemData.notificationDate ?? defaultDate()},
                                                            set: {itemData.notificationDate = $0}))
                    .labelsHidden()
                    .disabled(isEditing == false)
                }
            }
            Spacer()
            if isEditing {
                // 期限の有り無しを選択するボタン
                Image(systemName: datePickerIcon(date: editDate()))
                    .foregroundColor(editDate() == nil ? .orange : .gray)
                    .onTapGesture {
                        withAnimation {
                            // 編集中の項目がnilなら初期値を代入し、すでに日付があればnilを代入する
                            if editDate() == nil {
                                if isDeadLine {
                                    // 期限に代入
                                    itemData.deadLine = defaultDate()
                                } else {
                                    // 通知日時に代入
                                    itemData.notificationDate = defaultDate()
                                }
                            } else {
                                if isDeadLine {
                                    // 期限にnilを代入
                                    itemData.deadLine = nil
                                }
                                // 通知の日程をnilにする（共通の処理）
                                itemData.notificationDate = nil
                            }
                        }
                    }
            }
        } // HStack
    }
    // MARK: - メソッド
    // 行に表示するテキストを返す関数
    func rowTitle() -> String {
        if isDeadLine {
            return "期限:"
        } else {
            return "通知:"
        }
    }
    // 編集する日付を返す関数
    func editDate() -> Date? {
        if isDeadLine {
            return itemData.deadLine
        } else {
            return itemData.notificationDate
        }
    }
    // DatePickerの初期値を返す関数
    func defaultDate() -> Date {
        // 通知設定の時
        if isDeadLine == false {
            // 期限に設定された日付を初期値にする
            if let deadLine = itemData.deadLine {
                return deadLine
            }
        }
        // 期限は今日を初期値にする
        return Date()
    }
    // 日付設定で違う画像を返す関数
    private func datePickerIcon(date: Date?) -> String {
        if date == nil {
            return "calendar.badge.plus"
        } else {
            return "xmark.circle.fill"
        }
    }
}

struct ItemDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerRow(itemData: .constant(ItemData()), isEditing: .constant(true),
                      isDeadLine: true)
    }
}
