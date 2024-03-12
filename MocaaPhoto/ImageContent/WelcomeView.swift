//
//  WelcomeView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/12.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: ImageEditorViewModel
    var body: some View {
        VStack(spacing: 20){
            MButton(text: "Add Image", action: {
                // Handle the button tap
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
            }, color: .blue)
            
            // Text under the button
            Text("or drop an image")
                .foregroundColor(.gray)
        }
        .frame(width: 300, height: 250) // View size as requested
        .background(Color.white) // White canvas

    }
}

#Preview {
    WelcomeView(viewModel: ImageEditorViewModel())
}
