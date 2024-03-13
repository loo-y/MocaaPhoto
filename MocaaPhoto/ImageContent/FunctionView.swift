//
//  FunctionView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI

struct FunctionView: View {
    @State private var inputImage: NSImage?
    @State private var exifViewWidth: CGFloat = 220
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
                guard let image = viewModel.originalImage else { return }
                viewModel.isLoading = true
                let fujiFilmImage = viewModel.applyFujiFilmStyle(to: image)
                viewModel.originalImage = fujiFilmImage
                viewModel.createCombinedImage(from: fujiFilmImage)
                viewModel.isLoading = false
            }, color: .black)

            
            if !viewModel.cameraInfo.lensModel.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ExifLabelView(name: "Type", value: viewModel.cameraInfo.lensMake)
                        ExifLabelView(name: "Model", value: viewModel.cameraInfo.lensModel)
                        
                        HStack{
                            ExifLabelView(value: viewModel.cameraInfo.focalLength, width: exifViewWidth/2)
                            ExifLabelView(value: viewModel.cameraInfo.iso, width: exifViewWidth/2)
                        }
                        
                        HStack{
                            ExifLabelView(value: viewModel.cameraInfo.shutterSpeed)
                            ExifLabelView(value: viewModel.cameraInfo.aperture)
                        }
                    }
                    .padding()
                }
                .frame(width: exifViewWidth, height: 300)
            }
        }
        .frame(maxHeight: .infinity)
        .frame(width: 300)
//        .background(Color.gray)
        .background(Color(red: 232, green: 232, blue: 232))
    }
}

struct ExifLabelView: View {
    var name: String?
    var value: String
    var width: CGFloat? = nil

    var body: some View {
        HStack {
            if let name = name {
                Text(name)
                    .bold()
            }
            Spacer()
            Text(value)
            if name == nil {
                Spacer()
            }
        }
        .padding()
        .background(Color(white: 0.95))
        .cornerRadius(10)
        .shadow(radius: 3)
        .frame(width: width)
    }
}

#Preview {
    FunctionView(viewModel: ImageEditorViewModel())
}
