//
//  ImagePickerView.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/03/10.
//

import SwiftUI
//写真撮影する画面
struct ImagePickerView: UIViewControllerRepresentable {
    let controller = UIImagePickerController()
    
    // MARK: - Coordinator
    class Coordinator:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) {
            self.parent = parent
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
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView()
    }
}
