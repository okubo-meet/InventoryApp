//
//  RakutenAPI.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/04/01.
//

import SwiftUI

// MARK: - クラス
class RakutenAPI {
    // MARK: - 構造体
    /// JSONのデータ構造 （楽天市場API）
    private struct IchibaJson: Codable {
        // データを受け取る変数
        let Items: [Items]
    }
    /// JSONのitems内のデータ構造
    struct Items: Codable {
        /// 商品名
        let itemName: String
        /// 画像URL
        let mediumImageUrls: [String]
    }
    // MARK: - プロパティ
    /// APIで取得したデータの配列　登録画面で複数のデータが扱えるようにする
    static var resultItems: [ItemData] = []
    /// API検索で一度に取得できる上限
    static var readLimit = 10
    /// APIで取得した商品名
    var resultItemName = ""
    /// APIで取得した画像データ
    var resultImageData: Data?
    /// 商品検索の結果を表す変数
    var searchResult: SearchResult = .success
    // plistの値を受け取る変数
    private var property: [String: Any] = [:]
    // MARK: - イニシャライザ
    // 初期化　変数'property'に'Api.plist'の値を入れる
    init() {
        // Api.plistのパス取得
        let path = Bundle.main.path(forResource: "Api", ofType: "plist")
        // plistをDictionary形式で読み込み
        let configurations = NSDictionary(contentsOfFile: path!)
        if let datasourceDictionary: [String: Any] = configurations as? [String: Any] {
            property = datasourceDictionary
            print("plist:\(property)")
        }
    }
    // MARK: - メソッド
    /// 楽天市場APIを使用する関数
    func searchItem(itemCode: String, completion: @escaping(_ : SearchResult) -> Void ) {
        // ベースURL
        let baseURL = getProperty(key: "baseURL")
        // アプリケーションID
        let applicationId = getProperty(key: "applicationId")
        // 入力パラメータ（読み取った値）
        var requestParams = "&keyword=" + itemCode
        // 入力パラメータ（固定の値）
        let params: KeyValuePairs = ["format": "json",
                                     "formatVersion": "2",
                                     "hits": "1",
                                     "imageFlag": "1",
                                     "sort": "-updateTimestamp",
                                     "elements": "itemName,mediumImageUrls"]
        // パラメータをURLの形につなげる
        for (key, value) in params {
            requestParams += "&" + key + "=" + value
        }
        // URL作成
        let requestURL = baseURL + applicationId + requestParams
        print("リクエストURL: \(requestURL)")
        guard let url = URL(string: requestURL) else { return }
        // URLリクエストの生成
        let request = URLRequest(url: url, timeoutInterval: 8.0)
        // 非同期処理
        Task {
            do {
                print("データ取得開始")
                // リクエストのデータ取得
                let (data, _) = try await URLSession.shared.data(for: request)
                // デコード
                if let jsonData = try? JSONDecoder().decode(IchibaJson.self, from: data) {
                    // 商品名を取得
                    self.resultItemName = jsonData.Items[0].itemName
                    print("商品名" + self.resultItemName)
                    // 画像URLを取得
                    let urlString = jsonData.Items[0].mediumImageUrls[0]
                    print("画像URL:" + urlString)
                    guard let imageURL = URL(string: urlString) else { return }
                    // URLから画像データを取得
                    let data = try? Data(contentsOf: imageURL)
                    self.resultImageData = data
                    // 取得成功
                    self.searchResult = .success
                } else {
                    print("データがありません")
                    // 該当商品なし
                    self.searchResult = .failure
                }
            } catch {
                print("通信エラー")
                // エラー発生
                self.searchResult = .error
            }
            // クロージャ起動
            completion(self.searchResult)
            print("処理終了")
        }
    }
    /// plistから文字列を取得する関数
    private func getProperty(key: String) -> String {
        guard let value = property[key] as? String else {
            print("plist: エラー")
            return ""
        }
        print("plist: \(value)")
        return value
    }
}
