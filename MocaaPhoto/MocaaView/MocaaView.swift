//
//  MocaaView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/4.
//

import SwiftUI
import AppKit

struct MocaaView: View {
    @State private var aspectRatioWidth: CGFloat = 16
    @State private var aspectRatioHeight: CGFloat = 9
    @State private var ximage: NSImage?
    @State private var showingImagePicker = false
    @State private var outputImage: NSImage?
    @State private var backgroundImage: NSImage?
    @State private var windowSize: CGSize = .zero
    @State private var imagePadding: CGFloat = 300
    @EnvironmentObject var viewModel: AppViewModel
    // 将imageStore设置为环境对象
    @EnvironmentObject var imageStore: ImageStore

    func createOutputImage(image: NSImage) -> NSImage {
        let size = NSSize(width: 600, height: 400)
        let blurredImage = image.blurredOutput(radius: 10)
        let canvas = NSImage(size: size)
        canvas.lockFocus()

        blurredImage.draw(in: NSRect(origin: .zero, size: size))

        image.draw(in: NSRect(x: (size.width - image.size.width) / 2, y: (size.height - image.size.height) / 2, width: image.size.width, height: image.size.height), from: NSZeroRect, operation: .sourceOver, fraction: 1.0)

        canvas.unlockFocus()
        return canvas
    }

    func saveImageToDisk(image: NSImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.beginSheetModal(for: NSApp.keyWindow!) { result in
            if result == .OK, let url = panel.url {
                do {
                    try image.tiffRepresentation!.write(to: url)
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.black
            VStack(alignment: .center){
                
                if imageStore.currentImage != nil {
                    ZStack {
                        if let backgroundImage = backgroundImage {
//                            Image(nsImage: backgroundImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 600, height: 400)
//                                .clipped()
                            
                            Image(nsImage: backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
//                                .frame(width: windowSize.width, height: windowSize.height)
                                .clipped()
                                
                        }
                        
                        if let image = imageStore.currentImage {
                            let aspectRatio = image.size.width / image.size.height
                            let aspectedHeight = geometry.size.width * self.aspectRatioHeight / self.aspectRatioWidth
                            let imagePadding = aspectedHeight * 0.2
                            let imageWidth = aspectRatio * (aspectedHeight - imagePadding ) // min(geometry.size.width - imagePadding, aspectRatio * (aspectedHeight - imagePadding ))
                            let imageHeight = aspectedHeight - imagePadding // min(aspectedHeight - imagePadding, (geometry.size.width - imagePadding) / aspectRatio)


                            ZStack {
                                Image(nsImage: image)
                                    .resizable()
                                    .frame(width: imageWidth, height: imageHeight)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(0.0)
//                                    .shadow(color: .black, radius: 10)
                                    
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20)) // 添加圆角
                            .shadow(color: .black, radius: 50)
//

                        }
                    }
                    .padding(0.0)
//                    .background(Color.blue)
                    .frame(width: windowSize.width, height: windowSize.height)
                    .onTapGesture {
                        showingImagePicker = true
                    }
                    
//                    Button("Export") {
//                        if let image = imageStore.currentImage {
//                            let outputImage = createOutputImage(image: image)
//                            saveImageToDisk(image: outputImage)
//                        }
//                    }
                } else {
                    VStack(alignment: .center){
                        Button("Import Image") {
                            showingImagePicker = true
                            // 设置一个延迟来自动关闭sheet
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 3秒后
//                                showingImagePicker = false
//                            }
                        }
                        .frame(alignment: .center)
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
//                    .background(Color.black)
                    
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.width * self.aspectRatioHeight / self.aspectRatioWidth) // 设置VStack保持16:9的比例
            .clipped() // 如果VStack里的内容超出了设置的宽高，剪裁掉超出的部分
            .background(Color.black) // 给VStack设置背景色为黑色
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 将VStack居中显示
            
            
            .sheet(isPresented: $showingImagePicker) {
                
                ImagePicker(image: self.$imageStore.currentImage)
                    .onChange(of: imageStore.currentImage) { _ in
                        showingImagePicker = false
                    }
                    .onSubmit {
                        print("this is submit")
//                        showingImagePicker = false
                    }
                    .onDisappear {
                        print("this is disappear")
                        showingImagePicker = false
                        if let image = imageStore.currentImage {
                            self.backgroundImage = image.blurred(radius: 50)
                        }
                    }
                // Sheet的内容
//                Text("Here is the sheet")
//                showingImagePicker = false
            }
             // on size change
            .onChange(of: geometry.size) { _ in
                self.windowSize = geometry.size
            }
        }
        .padding(0.0)
        .edgesIgnoringSafeArea(.all) // 忽略安全区域，让背景色填满整个屏幕
//        .onChange(of: viewModel.triggerSaveAction) { _ in
//            print("trigger save")
//            DispatchQueue.main.async {
//                if let image = imageStore.currentImage {
//                    let outputImage = createOutputImage(image: image)
//                    self.saveImageToDisk(image: outputImage)
//                }
//            }
//
//        }
    }
    
}

extension NSImage {
    func blurredOutput(radius: CGFloat) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }
        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: cgImage)

        // 首先对图像进行边缘扩展，避免模糊边缘出现白色
        let extent = inputImage.extent.insetBy(dx: -radius * 2, dy: -radius * 2)
        let extendedImage = inputImage.clampedToExtent().cropped(to: extent)

        // 应用高斯模糊滤镜
        let blurFilter = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: extendedImage, kCIInputRadiusKey: radius])
        guard let outputImage = blurFilter?.outputImage else {
            return self
        }

        // 由于边缘扩展，需要裁剪回原始尺寸
        let croppedImage = outputImage.cropped(to: inputImage.extent)

        // 从处理后的CIImage创建CGImage
        guard let blurredCGImage = context.createCGImage(croppedImage, from: croppedImage.extent) else {
            return self
        }

        // 创建并返回新的NSImage
        return NSImage(cgImage: blurredCGImage, size: self.size)
    }
}


extension CGRect {
    func centered(in rect: CGRect) -> CGRect {
        var centeredRect = self
        centeredRect.origin.x = rect.midX - self.midX
        centeredRect.origin.y = rect.midY - self.midY
        return centeredRect
    }
}


#Preview {
    MocaaView()
}
