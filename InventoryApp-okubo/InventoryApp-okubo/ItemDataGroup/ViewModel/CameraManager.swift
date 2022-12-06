//
//  CameraManager.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/05/22.
//

import SwiftUI
import AVFoundation

class CameraManager {
    /// カメラのアクセス許可を確認する文字列を返す関数
    static func accessText() -> String {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            return "使用可能"
        } else {
            return "使用不可"
        }
    }
    /// カメラのアクセス許可を確認して拒否されているときアラートを返す関数
    static func cameraRequest(viewController: UIViewController, dismiss: DismissAction) {
        // 非同期処理
        Task {
            // カメラへのアクセス許可をリクエスト
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            // アクセスが拒否された場合アラート表示
            if granted {
                print("カメラ使用可能")
            } else {
                await viewController.present(requestAlert(dismiss: dismiss), animated: true, completion: nil)
            }
        }
    }
    /// カメラへのアクセス許可が取れなかった場合のアラートを返す関数
    static private func requestAlert(dismiss: DismissAction) -> UIAlertController {
        // カメラのアクセス認証状態
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        // アラートに表示するメッセージ
        var message: String
        // 認証状態によってメッセージを変更する
        if status == .denied {
            print("\(status): ユーザーによる拒否")
            message = "設定アプリでカメラへのアクセスを許可してください。"
        } else if status == .restricted {
            print("\(status): 機能制限による拒否")
            message = "カメラへのアクセスを試みましたが失敗しました。"
        } else {
            print("\(status): エラー")
            message = "予期せぬエラーが発生しました。"
        }
        let alert = UIAlertController(title: "カメラを使用できません", message: message, preferredStyle: .alert)
        // 前の画面に戻るボタン
        let back = UIAlertAction(title: "戻る", style: .default, handler: { _ in
            dismiss()
        })
        // 設定アプリを呼び出すボタン
        let setting = UIAlertAction(title: "設定", style: .default, handler: { _ in
            let url = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.open(url!)
        })
        alert.addAction(back)
        // ユーザーによる拒否の場合のみ設定のボタンを追加
        if status == .denied {
            alert.addAction(setting)
        }
        return alert
    }
}
