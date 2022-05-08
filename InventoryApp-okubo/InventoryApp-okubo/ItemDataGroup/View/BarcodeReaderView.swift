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
    private let searchLabel = UILabel()
    //動作の説明を表示するラベル
    private let guideLabel = UILabel()
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
    //商品検索終了時の振動のインスタンス
    private let finishImpact = UINotificationFeedbackGenerator()
    //効果音を扱うクラスのインスタンス
    private let soundPlayer = SoundPlayer()
    
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
                        //効果音再生
                        self.parent.soundPlayer.detectSound_play()
                        //キャプチャ停止
                        self.parent.captureSession.stopRunning()
                        //バーコード検索開始
                        self.parent.findBarcode(barcode: value)
                    }
                }
                
            }// VNDetectBarcodesRequest
            //検出するバーコードの種類を制限
            barcodesRequest.symbologies = [.ean8, .ean13]
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
        //Viewのサイズ(幅)
        let windowWidth = viewController.view.bounds.width
        //Viewのサイズ(高さ)
        let windowHeight = viewController.view.bounds.height
        setCamera()
        setPreviewLayer()
        setIndicator()
        setClose(windowWidth: windowWidth)
        setSearchLabel(windowWidth: windowWidth, windowHeight: windowHeight)
        setGuideLabel(windowWidth: windowWidth, windowHeight: windowHeight)
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
        barcodeBorder.lineWidth = 3
        barcodeBorder.fillColor = UIColor.clear.cgColor
        barcodeBorder.strokeColor = UIColor.orange.cgColor
        //表示
        previewLayer.addSublayer(barcodeBorder)
    }
    ///バーコードを検出した時にAPIを起動する
    func findBarcode(barcode: String) {
        // TODO: - バーコードを検知した瞬間のサウンドを探す -
        //インジケーター起動
        isLoading = true
        //ラベルのテキスト変更
        guideLabel.text = "検索中..."
        //API検索
        rakutenAPI.searchItem(itemCode: barcode)
    }
    ///商品検索に成功した場合のアラートを出す関数
    func successAlert() {
        //ラベルのテキスト変更
        guideLabel.text = rakutenAPI.resultItemName
        let alert = UIAlertController(title: "商品を検索しました", message: "前の画面に戻りますか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "戻る", style: .default, handler: { _ in
            dismiss()
        })
        let continuation = UIAlertAction(title: "続ける", style: .default, handler: { _ in
            self.captureSession.startRunning()
            self.guideLabel.text = "バーコードを写してください"
        })
        alert.addAction(ok)
        alert.addAction(continuation)
        //バイブレーション起動
        finishImpact.notificationOccurred(.success)
        //アラート表示
        viewController.present(alert, animated: true, completion: nil)
    }
    ///商品が見つからなかった場合のアラートを出す関数
    func failureAlert() {
        let alert = UIAlertController(title: "商品が見つかりませんでした", message: "楽天市場では扱っていない可能性があります。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
            self.guideLabel.text = "バーコードを写してください"
        })
        alert.addAction(ok)
        //バイブレーション起動
        finishImpact.notificationOccurred(.warning)
        //アラート表示
        viewController.present(alert, animated: true, completion: nil)
    }
    ///通信エラーが発生した場合のアラートを出す関数
    func errorAlert() {
        let alert = UIAlertController(title: "エラーが発生しました", message: "通信環境をご確認のうえ、再度実行してください。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
            self.guideLabel.text = "バーコードを写してください"
        })
        alert.addAction(ok)
        //バイブレーション起動
        finishImpact.notificationOccurred(.error)
        //アラート表示
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
    private func setClose(windowWidth: CGFloat) {
        //アイコンのサイズ
        let iconSize = windowWidth * 0.1
        //アイコンのサイズを適用
        var config = UIImage.SymbolConfiguration(pointSize: iconSize)
        //色の設定を追加
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .lightGray]))
        //ボタンのアイコン
        let closeIcon = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        //ボタンの位置
        let position = windowWidth * 0.05
        //戻るボタンの設定
        let closeButton = UIButton()
        closeButton.setImage(closeIcon, for: .normal)
        closeButton.frame = CGRect(x: position, y: position, width: iconSize, height: iconSize)
        closeButton.addAction(.init { _ in dismiss() }, for: .touchUpInside)
        //Viewに追加
        viewController.view.addSubview(closeButton)
    }
    ///商品検索に関するラベルをViewにセットする関数
    private func setSearchLabel(windowWidth: CGFloat, windowHeight: CGFloat) {
        //ラベルの位置
        let x = windowWidth * 0.5
        let y = windowWidth * 0.05
        //ラベルの大きさ
        let width = windowWidth * 0.45
        let height = windowHeight * 0.06
        //ラベル設定
        searchLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        searchLabel.text = "読み取った商品：0"
        searchLabel.textAlignment = .center
        searchLabel.textColor = .orange
        searchLabel.backgroundColor = .white
        searchLabel.layer.borderColor = UIColor.orange.cgColor
        searchLabel.layer.borderWidth = 2
        searchLabel.layer.masksToBounds = true
        searchLabel.layer.cornerRadius = height / 2
        //Viewに追加
        viewController.view.addSubview(searchLabel)
    }
    ///
    private func setGuideLabel(windowWidth: CGFloat, windowHeight: CGFloat) {
        
        guideLabel.frame = CGRect(x: windowWidth * 0.1, y: windowHeight * 0.8, width: windowWidth * 0.8, height: windowHeight * 0.05)
        guideLabel.text = "バーコードを写してください"
        guideLabel.textAlignment = .center
        guideLabel.textColor = .white
        guideLabel.backgroundColor = .black.withAlphaComponent(0.4)
        viewController.view.addSubview(guideLabel)
    }
}

//struct BarcodeReaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarcodeReaderView(item: .constant(TestData().items[0]))
//    }
//}
