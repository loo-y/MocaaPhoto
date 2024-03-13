//
//  FunctionView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI

struct FunctionView: View {
    @State private var inputImage: NSImage?
    @ObservedObject var viewModel: ImageEditorViewModel
//    let imageView: ImageView // 传入ImageView实例
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            MButton(text: "New Image", action: {
                viewModel.showImagePicker = true
                
                print("click in button load image")
                
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowedFileTypes = ["png", "jpg", "jpeg", "heic"]
                
                if panel.runModal() == .OK, let url = panel.url {
                    if let image = NSImage(contentsOf: url) {
                        viewModel.combinedImage = nil
                        viewModel.originalImagePath = url
                        viewModel.originalImage = image
                        inputImage = image
                        viewModel.isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.createCombinedImage(from: image)
                            viewModel.isLoading = false
                        }
                        
//                        viewModel.modifiedImage = createNewImage(from: image)
                    }
                }
            }, color: .blue)

            MButton(text: "Save Image", action: {
                viewModel.saveCombinedImage()
            }, color: .green)
            
            MButton(text: "Fujifilm Style", action: {
                guard let image = inputImage else { return }
                let fujiFilmImage = viewModel.applyFujiFilmStyle(to: image)
                viewModel.originalImage = fujiFilmImage
                viewModel.createCombinedImage(from: fujiFilmImage)
            }, color: .black)

        }
        .frame(maxHeight: .infinity)
        .frame(width: 300)
//        .background(Color.gray)
        .background(Color(red: 232, green: 232, blue: 232))
    }
}

#Preview {
    FunctionView(viewModel: ImageEditorViewModel())
}
