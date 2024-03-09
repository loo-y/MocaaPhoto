//
//  ContentView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI
import Combine
import AppKit
import Cocoa

struct ContentView: View {
    @StateObject private var viewModel = ImageEditorViewModel()
    
    var body: some View {
        HSplitView {
            ImageView(viewModel: viewModel) // 显示和编辑图片
            FunctionView(viewModel: viewModel) // 功能按钮区
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}

class ImageEditorViewModel: ObservableObject {
    @Published var showImagePicker: Bool = false
    @Published var originalImage: NSImage? = nil // 用于管理图片
    @Published var modifiedImage: NSImage? = nil
    @Published var combinedImage: NSImage? = nil
    @Published var text: String = "" // 用于管理文本
    // ... 其他跟编辑相关的状态

    private var snapshotSize: CGSize = .zero // 这里保存快照大小

    func updateSnapshotSize(_ size: CGSize) {
        snapshotSize = size
    }
    
    
    func createCombinedImage(from image: NSImage) {
        let aspectRatio: CGFloat = 16.0 / 9.0
        let originalSize = image.size
        let newHeight = originalSize.height * 1.4 // 40% taller
        let newWidth = newHeight * aspectRatio // width according to the 16:9 aspect ratio
        
        // Resize original image
        let resizedImage = createRoundedShadowImage(from: image, cornerRadius: 50, shadowColor: NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7), shadowBlurRadius: 100, shadowOffset: CGSize(width: 0, height: 0))
        let resizedSize = resizedImage.size
//        let resizedImage = image
        
        print("new width: \(newWidth)")
        print("original size: \(originalSize)")
        print("original width: \(originalSize.width)")
        // Create blurred background
        guard let blurredBackground = image.blurred(radius: 200)?.cropped(to: NSSize(width: originalSize.width, height: originalSize.height)) else {
            return
        }
        
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(newWidth), pixelsHigh: Int(newHeight), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep!)
        
        // Draw the blurred image as background
        blurredBackground.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        // Draw the original image in the center of the blurred background
        resizedImage.draw(in: NSRect(x: (newWidth - resizedSize.width) / 2, y: (newHeight - resizedSize.height) / 2, width: resizedSize.width, height: resizedSize.height), from: NSRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height), operation: .sourceOver, fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        if let finalImage = rep?.representation(using: .png, properties: [:]) {
            combinedImage = NSImage(data: finalImage)
        }
    }

//    func createRoundedShadowImage(from originalImage: NSImage, cornerRadius: CGFloat, shadowColor: NSColor, shadowBlurRadius: CGFloat, shadowOffset: CGSize) -> NSImage {
//        let imageSize = originalImage.size
//        let newWidth = imageSize.width + shadowOffset.width + shadowBlurRadius * 2
//        let newHeight = imageSize.height + abs(shadowOffset.height) + shadowBlurRadius * 2
//        let newImageSize = CGSize(width: newWidth, height: newHeight)
//        
//        let imageWithRoundedCorners = NSImage(size: imageSize)
//        
//        imageWithRoundedCorners.lockFocus()
//        let roundedPath = NSBezierPath(roundedRect: NSRect(origin: CGPoint.zero, size: imageSize), xRadius: cornerRadius, yRadius: cornerRadius)
//        roundedPath.addClip()
//        originalImage.draw(at: CGPoint.zero, from: NSRect(origin: CGPoint.zero, size: imageSize), operation: .copy, fraction: 1)
//        imageWithRoundedCorners.unlockFocus()
//        
//        let shadowedImage = NSImage(size: newImageSize)
//        
//        shadowedImage.lockFocus()
//        let context = NSGraphicsContext.current!.cgContext
//        context.interpolationQuality = .high
//        context.saveGState()
//        context.beginTransparencyLayer(auxiliaryInfo: nil)
//        
//        let drawingPoint = CGPoint(x: (newWidth - imageSize.width) / 2, y: (newHeight - imageSize.height) / 2)
//        
//        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
//        imageWithRoundedCorners.draw(at: drawingPoint, from: NSRect(origin: CGPoint.zero, size: imageSize), operation: .sourceOver, fraction: 1)
//        
//        context.endTransparencyLayer()
//        context.restoreGState()
//        shadowedImage.unlockFocus()
//        
//        return shadowedImage
//    }
    
    func createRoundedShadowImage(from originalImage: NSImage, cornerRadius: CGFloat, shadowColor: NSColor, shadowBlurRadius: CGFloat, shadowOffset: CGSize) -> NSImage {
        // 需要增加阴影的大小作为外边距
        let margins = shadowBlurRadius * 2
        let newImageSize = CGSize(width: originalImage.size.width + margins, height: originalImage.size.height + margins)
        let imageBounds = NSRect(x: shadowOffset.width + shadowBlurRadius, y: shadowOffset.height + shadowBlurRadius, width: originalImage.size.width, height: originalImage.size.height)

        let roundedImage = NSImage(size: originalImage.size)
        roundedImage.lockFocus()
        let roundedPath = NSBezierPath(roundedRect: CGRect(origin: .zero, size: originalImage.size), xRadius: cornerRadius, yRadius: cornerRadius)
        roundedPath.addClip()
        originalImage.draw(at: .zero, from: CGRect(origin: .zero, size: originalImage.size), operation: .copy, fraction: 1)
        roundedImage.unlockFocus()

        let shadowedImage = NSImage(size: newImageSize)
        shadowedImage.lockFocus()
        print("margins", margins)
        print("newImageSize", newImageSize)
        print("imageBounds", imageBounds)
        print(roundedImage.size)
        
        let context = NSGraphicsContext.current?.cgContext
        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
        roundedImage.draw(in: imageBounds)
//        roundedImage.draw(at: .zero, from: NSRect(origin: CGPoint.zero, size: originalImage.size), operation: .sourceOver, fraction: 1)

        shadowedImage.unlockFocus()
        
        return shadowedImage
    }
    
//    func createRoundedShadowImage(from originalImage: NSImage, cornerRadius: CGFloat, shadowColor: NSColor, shadowBlurRadius: CGFloat) -> NSImage {
//        let shadowOffset = CGSize(width: 0, height: -shadowBlurRadius)
//        let imageSize = originalImage.size
//        let newImageWidth = imageSize.width + shadowBlurRadius * 2
//        let newImageHeight = imageSize.height + shadowBlurRadius * 2
//        let newImageSize = CGSize(width: newImageWidth, height: newImageHeight)
//        let newImageRect = CGRect(x: shadowBlurRadius / 2, y: shadowBlurRadius / 2, width: imageSize.width, height: imageSize.height)
//
//        let newImage = NSImage(size: newImageSize)
//        newImage.lockFocus()
//
//        let context = NSGraphicsContext.current!.cgContext
//        context.interpolationQuality = .high
//        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
//
//        NSGraphicsContext.saveGraphicsState()
//
//        let clippingPath = NSBezierPath(roundedRect: newImageRect, xRadius: cornerRadius, yRadius: cornerRadius)
//        clippingPath.addClip()
//        
//        originalImage.draw(at: NSPoint(x: shadowBlurRadius / 2, y: shadowBlurRadius / 2), from: NSZeroRect, operation: .sourceOver, fraction: 1)
//
//        NSGraphicsContext.restoreGraphicsState()
//
//        newImage.unlockFocus()
//        return newImage
//    }
    
//    func createRoundedShadowImage(from originalImage: NSImage, cornerRadius: CGFloat, shadowColor: NSColor, shadowBlurRadius: CGFloat) -> NSImage {
//        let shadowOffset = NSSize(width: 0, height: -shadowBlurRadius)
//        let imageSize = originalImage.size
//        let newImageSize = NSSize(width: imageSize.width + shadowBlurRadius * 2, height: imageSize.height + shadowBlurRadius * 2)
//
//        let newImage = NSImage(size: newImageSize)
//        
//        newImage.lockFocus()
//        defer { newImage.unlockFocus() }
//        
//        let imageRect = NSRect(origin: CGPoint(x: shadowBlurRadius, y: shadowBlurRadius), size: imageSize)
//        let path = NSBezierPath(roundedRect: imageRect, xRadius: cornerRadius, yRadius: cornerRadius)
//
//        NSGraphicsContext.current?.shouldAntialias = true // Antialias edges
//        
//        // Draw shadow
//        let shadow = NSShadow()
//        shadow.shadowOffset = shadowOffset
//        shadow.shadowBlurRadius = shadowBlurRadius
//        shadow.shadowColor = shadowColor
//        shadow.set()
//
//        path.fill() // Applying the shadow to the context
//        originalImage.draw(in: imageRect) // Draw the original image
//
//        // Create clipping path for the rounded corners
//        NSGraphicsContext.current?.compositingOperation = .copy
//        let clipPath = NSBezierPath(roundedRect: imageRect, xRadius: cornerRadius, yRadius: cornerRadius)
//        clipPath.fill()
//        
//        NSGraphicsContext.current?.compositingOperation = .sourceOver // Reset the compositing operation
//        
//        return newImage
//    }
    
    func saveImageWithOriginalSize(backgroundImage: NSImage, overlayView: NSView) {
        let originalSize = backgroundImage.size
        let targetSize = CGSize(width: 8000, height: 4000) // 用你的原图尺寸替代这里

        // 首先，我们需要将 NSView 转换为 NSImage
        let overlayViewImage = NSImage(size: targetSize)
        overlayViewImage.lockFocus()
        overlayView.draw(overlayView.bounds)
        overlayViewImage.unlockFocus()
        
        let imageWithOverlay = NSImage(size: targetSize)
        guard let context = NSGraphicsContext.current else { return }
        // 2. 绘制原始图片
        backgroundImage.draw(in: CGRect(origin: .zero, size: targetSize))
        
        // 3. 绘制额外内容
        overlayViewImage.draw(in: CGRect(origin: .zero, size: targetSize))
        
        context.flushGraphics()
        imageWithOverlay.unlockFocus()

        
        // 将图像保存到文件系统
        guard let imageData = imageWithOverlay.tiffRepresentation,
              let fileURL = getSaveURL() else { return }
        
        do {
            try imageData.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    func saveCombinedImage() {
        // 将图像保存到文件系统
        if let saveImage = combinedImage {
            guard let imageData = saveImage.tiffRepresentation,
                  let fileURL = getSaveURL() else { return }
            
            do {
                try imageData.write(to: fileURL)
                print("Image saved to \(fileURL.path)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
    }
    
    func saveImage() {
        let view: ImageView = .init(viewModel: self)
        // 使用 snapshot 方法捕获图像
        guard let image = view.snapshot(size: snapshotSize) else { return }
                
        // 将图像保存到文件系统
        guard let imageData = image.tiffRepresentation,
              let fileURL = getSaveURL() else { return }
        
        do {
            try imageData.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    
    private func getSaveURL() -> URL? {
        // 实现方式可能取决于是否需要用户选择位置还是默认一个位置，以下是示例:
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.title = "Save your image"
        panel.message = "Choose a location to save your image"
        panel.nameFieldStringValue = "snapshot.png"
        
        let result = panel.runModal()
        return result == .OK ? panel.url : nil
    }
}

extension View {
    func snapshot(size: CGSize) -> NSImage? {
        // 创建NSHostingView 的实例来包含SwiftUI的View
        let hostingView = NSHostingView(rootView: self)
        // 指定视图大小
        hostingView.frame = CGRect(origin: .zero, size: size)
        
        // 创建基于位图的图形上下文
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else { return nil }
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
        
        // 生成图像
        let image = NSImage(size: bitmapRep.size)
        image.addRepresentation(bitmapRep)
        
        return image
    }
    
    // Internal method to calculate view size, this can be implemented differently
    // depending on how you wish to calculate or retrieve the size of your SwiftUI View
    private var size: CGSize {
        // Dummy view size, replace with your actual view dimensions
        return CGSize(width: 300, height: 300)
    }
}

extension NSImage {
    func resizeImage(to newSize: NSSize) -> NSImage {
        let img = NSImage(size: newSize)
        img.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize))
        img.unlockFocus()
        return img
    }
    
    func blurred(radius: CGFloat) -> NSImage? {
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
    
    func cropped(to size: NSSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        let context = NSGraphicsContext.current!
        context.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: size), from: NSRect(origin: CGPoint(x: (self.size.width - size.width) / 2, y: (self.size.height - size.height) / 2), size: self.size), operation: .copy, fraction: 1.0)
        img.unlockFocus()
        return img
    }
}
