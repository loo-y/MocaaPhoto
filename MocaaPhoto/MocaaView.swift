//
//  MocaaView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/4.
//

import SwiftUI
import AppKit

struct MocaaView: View {
    @State private var image: NSImage?
    @State private var showingImagePicker = false
    @State private var outputImage: NSImage?
    @State private var backgroundImage: NSImage?
    @State private var windowSize: CGSize = .zero
    @State private var imagePadding: CGFloat = 180

    func createOutputImage(image: NSImage) -> NSImage {
        let size = NSSize(width: 600, height: 400)
        let blurredImage = image.blurred(radius: 10)
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
            VStack(alignment: .center){
                if image != nil {
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
                        
                        if let image = image {
                            let aspectRatio = image.size.width / image.size.height
                            let imageWidth = min(geometry.size.width - imagePadding, aspectRatio * (geometry.size.height - imagePadding ))
                            let imageHeight = min(geometry.size.height - imagePadding, (geometry.size.width - imagePadding) / aspectRatio)


                            ZStack {
                                Image(nsImage: image)
                                    .resizable()
                                    .frame(width: imageWidth, height: imageHeight)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(0.0)
//                                    .shadow(color: .black, radius: 10)
                                    
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20)) // 添加圆角
                            .shadow(color: .black, radius: 5)
//

                        }
                    }
                    .padding(0.0)
//                    .background(Color.blue)
                    .frame(width: windowSize.width, height: windowSize.height)
                    .onTapGesture {
                        showingImagePicker = true
                    }
                    
                    Button("Export") {
                        if let image = image {
                            let outputImage = createOutputImage(image: image)
                            saveImageToDisk(image: outputImage)
                        }
                    }
                } else {
                    VStack(alignment: .center){
                        Button("Import Image") {
                            showingImagePicker = true
                        }
                        .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)
                    
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: self.$image)
                    .onDisappear {
                        if let image = self.image {
                            self.backgroundImage = image.blurred(radius: 0)
                        }
                    }
            }
             // on size change
            .onChange(of: geometry.size) { _ in
                self.windowSize = geometry.size
            }
        }
        .padding(0.0)
    }
    

}

extension NSImage {
    func blurred(radius: CGFloat) -> NSImage {
        let context = CIContext()
        let inputImage = CIImage(data: self.tiffRepresentation!)!

        
//        // 计算扩展后的图像大小
//        let extent = CGSize(width: self.size.width + 2 * radius, height: self.size.height + 2 * radius)
//
//        let inputImage = CIImage(cgImage: self.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
//
//        // 计算扩展后的矩形区域
//        let extendedRect = inputImage.extent.insetBy(dx: -radius, dy: -radius)
//        // 创建一个扩展后的 CIImage
//        let extendedImage = inputImage.clampedToExtent().applyingFilter("CICrop", parameters: [CIVector(cgRect: extendedRect)])


        
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return NSImage(cgImage: cgImage, size: self.size)
        }
        return self
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
