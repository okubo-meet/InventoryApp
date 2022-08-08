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
    // 編集中の商品データ
    @Binding var itemData: ItemData
    // 環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    // サンプル画像のカテゴリ
    @State var sampleImage: SampleImage = .food
    // グリッドのカラム
    private let rows: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    private let gridSize = UIScreen.main.bounds.width / 3.5
    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color.backgroundGray.ignoresSafeArea()
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
                                Button(action: {
                                    //　文字列からUIImageを作成
                                    let uiImage = UIImage(imageLiteralResourceName: image)
                                    // 画像をpngに変換
                                    if let imageData = uiImage.pngData() {
                                        // 編集中のデータに代入
                                        itemData.image = imageData
                                        // 画面を閉じる
                                        dismiss()
                                    }
                                }, label: {
                                    Image(image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: gridSize, height: gridSize, alignment: .center)
                                        .frame(minWidth: 0, maxWidth: .infinity,
                                               minHeight: 0, maxHeight: .infinity, alignment: .center)
                                        .background(Color.white)
                                        .border(Color.gray, width: 1)
                                })
                            }
                        }// LazyVGrid
                        .padding(.all)
                    }
                }// VStack
                .navigationTitle("サンプル画像")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("閉じる")
                        })
                    }
                }
            }// ZStack
        }// NavigationView
    }// body
}

struct ImageLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLibraryView(itemData: .constant(ItemData()))
    }
}
