//
//  BarcodeReaderView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
import AVFoundation
import Vision
//バーコードを読み取る画面　楽天APIを使用する予定
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
    //メタデータ出力のインスタンス
//    let metaDataOutput = AVCaptureMetadataOutput()
    
    // MARK: - Coordinator
    class Coordinator: AVCaptureSession, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: BarcodeReaderView
        init(_ parent: BarcodeReaderView) {
            self.parent = parent
        }
        
        //新たなビデオフレームが書き込むたびに呼び出されるデリゲートメソッド
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // フレームからImageBufferに変換
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            //バーコード検出用のVisionハンドラ
            let requestHandler = VNSequenceRequestHandler()
            //画像内のバーコードを検出するVsionリクエスト
            let barcodesRequest = VNDetectBarcodesRequest { result, _ in
                //バーコードがなければ処理なし
                guard let barcode = result.results?.first as? VNBarcodeObservation else {
                    return
                }
                //読み取ったコードを出力
                if let value = barcode.payloadStringValue {
                    print("読み取り：\(value)")
                    print("タイプ：\(barcode.symbology)")
                }
            }// VNDetectBarcodesRequest
            //バーコード検出開始
            try? requestHandler.perform([barcodesRequest], on: pixelBuffer, orientation: .downMirrored)
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
        //AVCaptureVideoDataOutputSampleBufferDelegateを呼び出す設定
        videoDataOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        //AVCaptureMetadataOutputObjectsDelegateを呼び出す設定
//        metaDataOutput.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        //映像からメタデータを出力できるよう設定
        captureSession.addOutput(videoDataOutput)
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
