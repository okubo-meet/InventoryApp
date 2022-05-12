//
//  ImagePickerView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
//写真撮影する画面
struct ImagePickerView: UIViewControllerRepresentable {
    // MARK: - プロパティ
    //環境変数で取得したdismissハンドラー
    @Environment(\.dismiss) var dismiss
    //編集中の商品データ
    @Binding var item: ItemData
    //UIImagePickerControllerのインスタンス
    private let controller = UIImagePickerController()
    
    // MARK: - Coordinator
    class Coordinator:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        //撮影して[Use Photo]を押したときに呼ばれるデリゲートメソッド
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[.originalImage] as? UIImage {
                let imageData = pickedImage.pngData()
                parent.item.image = imageData
            }
            //画面を閉じる
            parent.dismiss()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - View
    //生成時
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        controller.delegate = context.coordinator
        controller.sourceType = .camera
        return controller
    }
    //更新時
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        
    }
    
    // MARK: - メソッド
    func imageEdit(image: UIImage) -> UIImage {
        var newImage = UIImage()
        // TODO: - 本のカメラアプリを参考に画像の向きとサイズを編集する
        
        return newImage
    }
}

//struct ImagePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerView()
//    }
//}
