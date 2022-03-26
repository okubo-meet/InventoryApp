//
//  BarcodeReaderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
import AVFoundation

struct BarcodeReaderView: UIViewControllerRepresentable {
    //環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    //UIViewControllerのインスタンス生成
    private let viewController = UIViewController()
    // セッションのインスタンス
    private let captureSession = AVCaptureSession()
    //カメラ映像のプレビューレイヤー
    private let previewLayer = AVCaptureVideoPreviewLayer()
    //ビデオデータ出力のインスタンス
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: - Coordinator
    class Coordinator: AVCaptureSession {
        let parent: BarcodeReaderView
        init(_ parent: BarcodeReaderView) {
            self.parent = parent
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - View
    //画面起動時
    func makeUIViewController(context: UIViewControllerRepresentableContext<BarcodeReaderView>) -> UIViewController {
        //Viewのサイズ(画面全体)
        viewController.view.frame = UIScreen.main.bounds
        setCamera()
        setPreviewLayer()
        //キャプチャーセッション開始
        captureSession.startRunning()
        return viewController
    }
    //画面更新時
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<BarcodeReaderView>) {
        
    }
    // MARK: - メソッド
    ///カメラの設定をする関数
    func setCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        //撮影している情報をセッションに渡す
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
    }
    ///カメラのキャプチャ映像をViewにセットする関数
    func setPreviewLayer() {
        //プレビューするキャプチャを設定
        previewLayer.session = captureSession
        //プレビューの画面サイズ
        previewLayer.frame = viewController.view.bounds
        //矩形領域の表示
        previewLayer.videoGravity = .resizeAspectFill
        //プレビューをViewに追加
        viewController.view.layer.addSublayer(previewLayer)
    }
}

struct BarcodeReaderView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeReaderView()
    }
}
