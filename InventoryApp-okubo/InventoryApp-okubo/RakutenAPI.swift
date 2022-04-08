//
//  RakutenAPI.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/04/01.
//

import SwiftUI

// MARK: - プロトコル
protocol SearchItemDelegate {
    //商品検索が終わったときの処理
    func searchItemDidfinish(isSuccess: Bool)
}
// MARK: -　クラス
class RakutenAPI: ObservableObject {
    // MARK: - 構造体
    ///JSONのデータ構造 （楽天市場API）
    struct IchibaJson: Codable {
        ///JSONのitems内のデータ構造
        struct Items: Codable {
            ///商品名
            let itemName: String
            ///画像URL
            let smallImageUrls: [String]
            let mediumImageUrls: [String]
        }
        //データを受け取る変数
        let Items: [Items]
    }
    // MARK: - プロパティ
    //検索終了時のデリゲート
    var delegate: SearchItemDelegate?
    //plistの値を受け取る変数
    private var property: Dictionary<String, Any> = [:]
    //初期化　変数'property'に'Api.plist'の値を入れる
    init() {
        //Api.plistのパス取得
        let path = Bundle.main.path(forResource: "Api", ofType: "plist")
        //plistをDictionary形式で読み込み
        let configurations = NSDictionary(contentsOfFile: path!)
        if let datasourceDictionary: [String : Any] = configurations as? [String: Any] {
            property = datasourceDictionary
            print("plist:\(property)")
        }
    }
    
    // MARK: - メソッド
    ///plistから文字列を取得する関数
    func getProperty(key: String) -> String {
        guard let value = property[key] as? String else {
            print("plist: エラー")
            return ""
        }
        print("plist: \(value)")
        return value
    }
    ///楽天市場APIを使用する関数
    func searchItem(itemCode: String) {
        //ベースURL
        let baseURL = getProperty(key: "baseURL")
        //アプリケーションID
        let applicationId = getProperty(key: "applicationId")
        //入力パラメータ（読み取った値）
        var requestParams = "&keyword=" + itemCode
        //入力パラメータ（固定の値）
        let params: KeyValuePairs = ["format" : "json",
                                     "formatVersion" : "2",
                                     "hits" : "1",
                                     "elements" : "itemName,smallImageUrls,mediumImageUrls"]
        //パラメータをURLの形につなげる
        for (key, value) in params {
            requestParams += "&" + key + "=" + value
        }
        //URL作成
        let requestURL = baseURL + applicationId + requestParams
        print("リクエストURL: \(requestURL)")
        guard let url = URL(string: requestURL) else { return }
        //URLリクエストの生成
        let request = URLRequest(url: url)
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let itemData = data {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(IchibaJson.self, from: itemData)
                    print("\(jsonData.Items[0])")
                    //メインスレッドでアラートを起動
                    DispatchQueue.main.async {
                        self.delegate?.searchItemDidfinish(isSuccess: true)
                    }
                } else {
                    print("データがありません")
                    DispatchQueue.main.async {
                        self.delegate?.searchItemDidfinish(isSuccess: false)
                    }
                }
            } catch {
                print("エラー：\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.searchItemDidfinish(isSuccess: false)
                }
            }
        }
        //セッション開始
        session.resume()
    }// searchItem
}
