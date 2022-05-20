//
//  ImageLibraryView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
// サンプル画像を選択する画面
struct ImageLibraryView: View {
    // MARK: - プロパティ
    // サンプル画像のカテゴリ
    @State var sampleImage: SampleImage = .food
    // グリッドのカラム
    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    private let gridWidth = UIScreen.main.bounds.width / 3.5
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                // カテゴリ別に表示する画像を入れ替える
                Picker("", selection: $sampleImage) {
                    ForEach(SampleImage.allCases, id: \.self) { index in
                        Text(index.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                ScrollView {
                    // サンプル画像のグリッド
                    LazyVGrid(columns: rows, alignment: .center, spacing: 10) {
                        ForEach(sampleImage.toImageString(), id: \.self) { image in
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: gridWidth, height: gridWidth, alignment: .center)
                                .frame(minWidth: 0, maxWidth: .infinity,
                                       minHeight: 0, maxHeight: .infinity, alignment: .center)
                                .border(Color.black)
                        }
                    }// LazyVGrid
                    .padding(.all)
                }
            }// VStack
            .navigationTitle("サンプル画像")
        }// NavigationView
    }// body
}

struct ImageLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLibraryView()
    }
}
