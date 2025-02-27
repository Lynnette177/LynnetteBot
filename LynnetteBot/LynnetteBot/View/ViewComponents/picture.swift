//
//  picture.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/17.
//
import SwiftUI
struct URLImageView: View {
    @State private var image: UIImage? = nil
    let url: URL
    let size: CGSize

    var body: some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
                .contextMenu {
                    Button(action: {
                        copyImageToClipboard()
                    }) {
                        Text("复制图片")
                        Image(systemName: "doc.on.clipboard")
                    }
                    Button(action: {
                        saveImageToAlbum(image: uiImage)
                    }) {
                        Label("保存到相册", systemImage: "photo.on.rectangle.angled")
                    }
                    Button(action: {
                        // 触发分享
                        shareImage(image: uiImage)
                    }) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
        } else {
            ProgressView() // 显示加载中的进度指示器
                .onAppear {
                    loadImage()
                }
                .frame(width: size.width, height: size.height)
                .overlay(
                    VStack{
                        Spacer()
                        Text("绘图完毕！加载中...")
                    }
                )
        }
    }
    private func copyImageToClipboard() {
        guard let uiImage = image else { return }
        UIPasteboard.general.image = uiImage
    }
    private func saveImageToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    private func loadImage() {
        // 异步加载图片
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isImagePickerPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }
    
    @Binding var isImagePickerPresented: Bool
    @Binding var selectedImage: UIImage?
    var isCamera: Bool // 用来控制选择相机还是相册
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = isCamera ? .camera : .photoLibrary // 根据 `isCamera` 决定是相机还是相册
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
