//
//  FunctionView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI

struct FunctionView: View {
    @ObservedObject var viewModel: ImageEditorViewModel
//    let imageView: ImageView // 传入ImageView实例
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Button("Load Image"){
                viewModel.showImagePicker = true
                
                print("click in button load image")
                
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowedFileTypes = ["png", "jpg", "jpeg", "heic"]
                
                if panel.runModal() == .OK, let url = panel.url {
                    if let image = NSImage(contentsOf: url) {
                        viewModel.originalImagePath = url
                        viewModel.originalImage = image
                        viewModel.createCombinedImage(from: image)
//                        viewModel.modifiedImage = createNewImage(from: image)
                    }
                }
                
            }
            // 实现功能按钮界面
            Button("Save Image") {
                // 调用viewModel中的saveImage函数，传入imageView
                viewModel.saveCombinedImage()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
//        .background(Color.gray)
        .background(Color(red: 232, green: 232, blue: 232))
    }
}
