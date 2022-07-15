//
//  FolderEditView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/08.
//

import SwiftUI
// フォルダを編集する画面
struct FolderEditView: View {
    // MARK: - プロパティ
    // 仮のデータ
    @EnvironmentObject var testData: TestData
    // 環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    // 保存済みのフォルダを判別するインデックス番号
    @Binding var folderIndex: Int?
    // 編集するフォルダ
    @State var editFolder = FolderData(name: "", isStock: true, icon: Icon.house.rawValue)
    // フォルダ保存アラートのフラグ
    @State private var saveAlert = false
    // フォルダ削除アラートのフラグ
    @State private var deleteAlert = false
    // 効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("フォルダ名")
                        TextField("入力してください", text: $editFolder.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    Picker("種類", selection: $editFolder.isStock, content: {
                        Text("在庫リスト").tag(true)
                        Text("買い物リスト").tag(false)
                    })
                    Picker("アイコン", selection: $editFolder.icon, content: {
                        ForEach(Icon.allCases, id: \.self) { icon in
                            Image(systemName: icon.rawValue).tag(icon.rawValue)
                                .foregroundColor(.orange)
                        }
                    })
                }
                Section {
                    // 既存フォルダの削除ボタン
                    if folderIndex != nil {
                        Button(action: {
                            // 削除アラート起動
                            deleteAlert.toggle()
                            soundPlayer.deleteVibrationPlay()
                        }, label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("フォルダを削除する")
                            }
                        })
                        .foregroundColor(.red)
                    }
                }
            }// Form
            // 保存アラート
            .alert("フォルダを保存しました", isPresented: $saveAlert, actions: {
                Button("OK") {
                    dismiss()
                }
            }, message: {
                Text("前の画面に戻ります")
            })
            // 削除アラート
            .alert("フォルダを削除します", isPresented: $deleteAlert, actions: {
                Button("削除", role: .destructive) {
                    if let index = folderIndex {
                        testData.items.removeAll(where: {$0.folder == editFolder.name})
                        testData.folders.remove(at: index)
                    }
                    dismiss()
                }
            }, message: {
                Text("このフォルダに保存されたデータも削除されます")
            })
            .navigationTitle("フォルダ設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                // 画面を閉じるボタン
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("閉じる") {
                        dismiss()
                    }
                })
                // 保存ボタン
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("保存") {
                        // フォルダ設定保存の処理
                        if let index = folderIndex {
                            // フォルダの商品データ
                            let items = testData.items.filter({$0.folder == testData.folders[index].name})
                            for item in items {
                                // 商品データのインデックス番号を取得して保存先を更新
                                if let index = testData.items.firstIndex(where: {$0.id == item.id}) {
                                    testData.items[index].folder = editFolder.name
                                    print("\(testData.items[index])")
                                }
                            }
                            // 更新
                            testData.folders[index] = editFolder
                        } else {
                            // 追加
                            testData.folders.append(editFolder)
                        }
                        // 保存完了アラート起動
                        saveAlert.toggle()
                        soundPlayer.saveSoundPlay()
                    }
                    .disabled(editFolder.name == "")
                })
            })// toolbar
        }// NavigationView
        .onAppear {
            // フォルダのインデックス番号がnilの時は新規作成
            if let index = folderIndex {
                print("既存のフォルダ： \(testData.folders[index])")
                editFolder = testData.folders[index]
                print("代入:\(editFolder)")
            } else {
                print("新規作成")
            }
        }
    }// View
}

struct FolderEditView_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditView(folderIndex: .constant(nil))
    }
}
