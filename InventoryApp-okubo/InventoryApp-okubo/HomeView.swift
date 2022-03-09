//
//  HomeView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/07.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: RegisterView()) {
                    Text("登録画面へ")
                }
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
