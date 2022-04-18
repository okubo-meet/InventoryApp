//
//  HomeView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI
//起動時の画面　TabViewで扱うView
struct HomeView: View {
    //仮のデータ
    @EnvironmentObject var testData: TestData
    private let screenWidth = CGFloat(UIScreen.main.bounds.width)
    private let screenHeight = CGFloat(UIScreen.main.bounds.height)
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("最近の項目")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    NavigationLink(destination: RecentItemsView()) {
                        Text("すべて表示")
                    }
                    .padding()
                }// HStack
                //最近の項目
                ScrollView(.horizontal) {
                    HStack {
                        RecentRowView(category: "賞味期限通知")
                        .frame(width: screenHeight / 4, height: screenHeight / 4, alignment: .center)
                        RecentRowView(category: "買い物リスト")
                        .frame(width: screenHeight / 4, height: screenHeight / 4, alignment: .center)
                        RecentRowView(category: "今日")
                        .frame(width: screenHeight / 4, height: screenHeight / 4, alignment: .center)
                    }// HStack
                }// ScrollView
                .frame(width: screenWidth, height: screenHeight / 4, alignment: .center)
                .background(Color.background)
                Spacer()
                //画面遷移ボタン
                NavigationLink(destination: RegisterView()) {
                    Text("登録画面へ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: screenWidth / 2, height: screenHeight / 10, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 40).shadow(color: .gray.opacity(0.5), radius: 5, x: 1, y: 1))
                }
                Spacer()
            }// VStack
            .navigationTitle("ホーム")
        }// NavigationView
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
