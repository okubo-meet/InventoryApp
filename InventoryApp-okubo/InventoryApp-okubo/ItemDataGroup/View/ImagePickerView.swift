//
//  ImagePickerView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
// 写真撮影する画面
struct ImagePickerView: UIViewControllerRepresentable {
    // MARK: - プロパティ
    // 環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    // 編集中の商品データ
    @Binding var item: ItemData
    // UIImagePickerControllerのインスタンス
    private let imagePickerController = UIImagePickerController()
    // MARK: - Coordinator
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        // 撮影して[Use Photo]を押したときに呼ばれるデリゲートメソッド
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // トリミングした画像を使う
            if let pickedImage = info[.editedImage] as? UIImage {
                // 画像データをpngからjpegに変えたら画像の向きの不具合は解決した
                let imageData = pickedImage.jpegData(compressionQuality: 1.0)
                parent.item.image = imageData
            }
            // 画面を閉じる
            parent.dismiss()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    // MARK: - View
    // 生成時
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>)
    -> UIImagePickerController {
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType = .camera
        // 撮影後のトリミングを有効
        imagePickerController.allowsEditing = true
        return imagePickerController
    }
    // 更新時
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePickerView>) {
        // 処理無し
    }
}
