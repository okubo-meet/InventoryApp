//
//  ItemDataView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/22.
//

import SwiftUI

struct ItemDataView: View {
    ///表示するデータ
    @Binding var itemData: ItemData
    private let imageSize = CGFloat(UIScreen.main.bounds.width) / 2
    var body: some View {
        VStack {
            Image("pork-loin")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .border(Color.black, width: 1)
            List {
                HStack {
                    Text("商品名:")
                    TextField("入力してください", text: $itemData.name)
                }
                //DatePickerで選択できるようにする。期限無しも選択できるようにする
                HStack {
                    Text("期限:")
                    Text(dateText(date: itemData.deadLine))
                }
                //期限の何日前か計算して表示する
                HStack {
                    Text("通知:")
                    Text(dateText(date: itemData.notificationDate))
                }
                HStack {
                    Text("個数:")
                    Stepper(value: $itemData.numberOfItems) {
                        Text("\(itemData.numberOfItems)個")
                    }
                }
                //Pickerのデザインを検討
                HStack{
                    Text("状態:")
                    Picker("選択", selection: $itemData.status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                //保存先はCoreDataに登録されているフォルダから選択できるようにする
                HStack {
                    Text("保存先:")
                    Text(itemData.folder)
                }
                //登録日は編集できない
                HStack {
                    Text("登録日:")
                    Text(dateText(date: itemData.registrationDate))
                }
            }
            .listStyle(.plain)
        }// VStack
        
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

struct ItemDataView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDataView(itemData: .constant(TestData().items[0]))
    }
}
