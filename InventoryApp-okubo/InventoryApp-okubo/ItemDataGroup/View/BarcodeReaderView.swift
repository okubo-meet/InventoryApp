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
    // MARK: - プロパティ
    //環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    //仮のデータ
    @EnvironmentObject var testData: TestData
    //楽天APIを扱うクラス
    @ObservedObject var rakutenAPI = RakutenAPI()
    //編集中の商品データ
    @Binding var item: ItemData
    ///インジケーター切り替えフラグ
    @State var isLoading = false
    //バーコードの位置に表示する線
    var barcodeBorder = CAShapeLayer()
    //バーコード検索の状態を表示するラベル
    private let label = UILabel()
    //UIViewControllerのインスタンス生成
    private let viewController = UIViewController()
    //インジケーター
    private let indicatorView = UIActivityIndicatorView()
    // セッションのインスタンス
    private let captureSession = AVCaptureSession()
    //カメラ映像のプレビューレイヤー
    private let previewLayer = AVCaptureVideoPreviewLayer()
    //ビデオデータ出力のインスタンス
    private let videoDataOutput = AVCaptureVideoDataOutput()
    //画面サイズ
    private let screenWidth = CGFloat(UIScreen.main.bounds.width)
    private let screenHeight = CGFloat(UIScreen.main.bounds.height)
    
    // MARK: - Coordinator
    class Coordinator: AVCaptureSession, AVCaptureVideoDataOutputSampleBufferDelegate, SearchItemDelegate {
        
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
                DispatchQueue.main.async {
                    //バーコードがなければ処理なし
                    guard let barcode = result.results?.first as? VNBarcodeObservation else {
                        //バーコードを検知していないとき枠線を非表示にする
                        self.parent.barcodeBorder.removeFromSuperlayer()
                        return
                    }
                    //線を表示
                    self.parent.showBorder(barcode: barcode)
                    //読み取ったコードを出力
                    if let value = barcode.payloadStringValue {
                        print("読み取り：\(value)")
                        print("タイプ：\(barcode.symbology)")
                        self.parent.captureSession.stopRunning()
                        self.parent.searchAlert(barcode: value)
                    }
                }
                
            }// VNDetectBarcodesRequest
            //バーコード検出開始
            try? requestHandler.perform([barcodesRequest], on: pixelBuffer, orientation: .downMirrored)
        }
        //商品検索が終わったときのデリゲートメソッド
        func searchItemDidfinish(isSuccess: Bool) {
            //インジケーター停止
            parent.isLoading = false
            if isSuccess {
                DispatchQueue.main.async {
                    self.parent.item.name = self.parent.rakutenAPI.resultItemName
                    self.parent.item.image = self.parent.rakutenAPI.resultImageData
                }
                parent.successAlert()
            } else {
                parent.failureAlert()
            }
        }
        //APIでエラーが発生したときのデリゲートメソッド
        func searchItemError() {
            //インジケーター停止
            parent.isLoading = false
            parent.errorAlert()
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
        setIndicator()
        setClose()
        setSearchLabel()
        //読み取り成功ラベル
        //SearchItemDelegateを呼び出す設定
        rakutenAPI.delegate = context.coordinator
        //AVCaptureVideoDataOutputSampleBufferDelegateを呼び出す設定
        videoDataOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        //映像からメタデータを出力できるよう設定
        captureSession.addOutput(videoDataOutput)
        //キャプチャーセッション開始
        captureSession.startRunning()
        return viewController
    }
    //画面更新時
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<BarcodeReaderView>) {
        if isLoading {
            indicatorView.startAnimating()
            
        } else {
            indicatorView.stopAnimating()
        }
    }
    
    // MARK: - メソッド
    ///検知したバーコードの位置に線を表示する関数
    func showBorder(barcode: VNBarcodeObservation) {
        let boxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: barcode.boundingBox)
        let boxPath = CGPath(rect: boxOnScreen, transform: nil)
        barcodeBorder.path = boxPath
        barcodeBorder.lineWidth = 5
        barcodeBorder.fillColor = UIColor.clear.cgColor
        barcodeBorder.strokeColor = UIColor.orange.cgColor
        //表示
        previewLayer.addSublayer(barcodeBorder)
    }
    ///バーコードを検出した時にアラートを出す関数
    func searchAlert(barcode: String) {
        let alert = UIAlertController(title: "バーコードを検出しました", message: "楽天市場で検索します", preferredStyle: .alert)
        let serch = UIAlertAction(title: "検索", style: .default, handler: { _ in
            //インジケーター起動
            self.isLoading = true
            //ラベルのテキスト変更
            self.label.text = "検索中..."
            //API検索
            self.rakutenAPI.searchItem(itemCode: barcode)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            self.captureSession.startRunning()
        })
        alert.addAction(cancel)
        alert.addAction(serch)
        viewController.present(alert, animated: true, completion: nil)
    }
    ///商品検索に成功した場合のアラートを出す関数
    func successAlert() {
        //ラベルのテキスト変更
        label.text = "読み取り完了"
        let alert = UIAlertController(title: "商品を検索しました", message: "前の画面に戻りますか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "戻る", style: .default, handler: { _ in
            dismiss()
        })
        let continuation = UIAlertAction(title: "続行", style: .default, handler: { _ in
            self.captureSession.startRunning()
        })
        alert.addAction(ok)
        alert.addAction(continuation)
        viewController.present(alert, animated: true, completion: nil)
    }
    ///商品が見つからなかった場合のアラートを出す関数
    func failureAlert() {
        let alert = UIAlertController(title: "商品が見つかりませんでした", message: "楽天市場では扱っていない可能性があります。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
        })
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }
    ///通信エラーが発生した場合のアラートを出す関数
    func errorAlert() {
        let alert = UIAlertController(title: "通信エラーが発生しました", message: "通信環境をご確認のうえ、再度実行してください。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
        })
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }
    ///カメラの設定をする関数
    private func setCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        //撮影している情報をセッションに渡す
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
    }
    ///カメラのキャプチャ映像をViewにセットする関数
    private func setPreviewLayer() {
        //プレビューするキャプチャを設定
        previewLayer.session = captureSession
        //プレビューの画面サイズ
        previewLayer.frame = viewController.view.bounds
        //矩形領域の表示
        previewLayer.videoGravity = .resizeAspectFill
        //プレビューをViewに追加
        viewController.view.layer.addSublayer(previewLayer)
    }
    ///インジケーターをViewにセットする関数
    private func setIndicator() {
        //インジケーター設定
        indicatorView.style = .large
        indicatorView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        indicatorView.center = viewController.view.center
        indicatorView.color = .orange
        indicatorView.backgroundColor = .white
        indicatorView.layer.cornerRadius = 25
        indicatorView.layer.opacity = 0.6
        //Viewに追加
        viewController.view.addSubview(indicatorView)
    }
    ///画面を閉じるボタンをViewにセットする関数
    private func setClose() {
        //アイコンのサイズ
        let iconSize = screenWidth / 9
        //アイコンのサイズを適用
        var config = UIImage.SymbolConfiguration(pointSize: iconSize)
        //色の設定を追加
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .lightGray]))
        //ボタンのアイコン
        let closeIcon = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        //ボタンの位置
        let position = screenWidth / 15
        //戻るボタンの設定
        let closeButton = UIButton()
        closeButton.setImage(closeIcon, for: .normal)
        closeButton.frame = CGRect(x: position, y: position, width: iconSize, height: iconSize)
        closeButton.addAction(.init { _ in dismiss() }, for: .touchUpInside)
        //Viewに追加
        viewController.view.addSubview(closeButton)
    }
    ///商品検索に関するラベルをViewにセットする関数
    private func setSearchLabel() {
        //ラベルの位置
        let x = screenWidth - screenWidth / 2.5
        let y = screenWidth / 15
        //ラベルの大きさ
        let width = screenWidth / 3
        let height = screenHeight / 15
        //ラベル設定
        label.frame = CGRect(x: x, y: y, width: width, height: height)
        label.text = "読み取り中"
        label.textAlignment = .center
        label.textColor = .orange
        label.backgroundColor = .white
        label.layer.borderColor = UIColor.orange.cgColor
        label.layer.borderWidth = 2
        label.layer.masksToBounds = true
        label.layer.cornerRadius = height / 2
        //Viewに追加
        viewController.view.addSubview(label)
    }
}

struct BarcodeReaderView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeReaderView(item: .constant(TestData().items[0]))
    }
}
