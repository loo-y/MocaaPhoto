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
import ImageIO
import CoreImage

struct ContentView: View {
    @StateObject private var viewModel = ImageEditorViewModel()
    
    var body: some View {
        VSplitView {
            ImageView(viewModel: viewModel) // 显示和编辑图片
            FunctionView(viewModel: viewModel) // 功能按钮区
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}

// 定义一个结构体来存储你想要的相机信息
struct CameraInfo {
    var lensMake: String = ""
    var lensModel: String = ""
    var focalLength: String = ""
    var aperture: String = ""
    var shutterSpeed: String = ""
    var iso: String = ""
    var dateTimeOriginal: String = ""
}

class ImageEditorViewModel: ObservableObject {
    @Published var showImagePicker: Bool = false
    @Published var originalImagePath: URL? = nil
    @Published var originalImage: NSImage? = nil // 用于管理图片
    @Published var modifiedImage: NSImage? = nil
    @Published var combinedImage: NSImage? = nil
    
    @Published var text: String = "" // 用于管理文本
    // ... 其他跟编辑相关的状态

    private var snapshotSize: CGSize = .zero // 这里保存快照大小

    func updateSnapshotSize(_ size: CGSize) {
        snapshotSize = size
    }

    func applyFujiFilmStyle(to inputImage: NSImage) -> NSImage {
        // 确保有CGImage来进行处理
        let fixedImage = inputImage
        guard let cgImage = fixedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return inputImage
        }

        let ciImage = CIImage(cgImage: cgImage)
        
        // 创建并组合多个滤镜
        guard let colorfulControlsFilter = CIFilter(name: "CIColorControls"),
              let photoEffectFilter = CIFilter(name: "CIPhotoEffectInstant"),
              let colorMatrixFilter = CIFilter(name: "CIColorMatrix") else {
            return inputImage
        }

        // 调整亮度、对比度和饱和度
        colorfulControlsFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorfulControlsFilter.setValue(0.1, forKey: kCIInputBrightnessKey)
        colorfulControlsFilter.setValue(1.2, forKey: kCIInputContrastKey) // 提高对比度以模仿胶片效果
        colorfulControlsFilter.setValue(1.1, forKey: kCIInputSaturationKey)
        
        // 应用照片效果滤镜来模拟即时相片风格
        if let outputImage = colorfulControlsFilter.outputImage {
            photoEffectFilter.setValue(outputImage, forKey: kCIInputImageKey)
        }
        
        // 使用颜色矩阵滤镜可以微调颜色（例如，增加特定通道的强度）
        // colorMatrixFilter可以用来调整指定颜色分量，这里只是一个基础的示例
//        if let outputImage = photoEffectFilter.outputImage {
//            colorMatrixFilter.setValue(outputImage, forKey: kCIInputImageKey)
//            colorMatrixFilter.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector") // 修改红色分量
//            colorMatrixFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector") // 修改绿色分量
//            colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector") // 修改蓝色分量
//            colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector") // 透明度分量保持不变
//        }
        
        // 获取最终调整过的图像
        if let outputImage = photoEffectFilter.outputImage {
            let context = CIContext(options: nil)
            if let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: outputCGImage, size: fixedImage.size)
            }
        }
        return inputImage
        
//        // ========== 自带滤镜的调整方法 start ==========
//        // CIFalseColor： 将图像映射到一个由两种颜色组成的颜色空间。它将色阶替换为提供的两种颜色，创造出类似热成像或伪色效果。
//        let falseColorFilter = CIFilter(name: "CIFalseColor")
//        falseColorFilter?.setValue(combinedImage, forKey: kCIInputImageKey)
//        falseColorFilter?.setValue(CIColor.red, forKey: "inputColor0")
//        falseColorFilter?.setValue(CIColor.blue, forKey: "inputColor1")
//        
//        // CIHueAdjust： 用于调整图像色调的值。给定一个角度值来旋转色相
//        let hueAdjustFilter = CIFilter(name: "CIHueAdjust")
//        hueAdjustFilter?.setValue(combinedImage, forKey: kCIInputImageKey)
//        hueAdjustFilter?.setValue(1.57, forKey: "inputAngle") // 旋转色相约 90 度
//        
//        // CIColorControls： 用于调整图像的饱和度、亮度和对比度。
//        let colorControlsFilter = CIFilter(name: "CIColorControls")
//        colorControlsFilter?.setValue(combinedImage, forKey: kCIInputImageKey)
//        colorControlsFilter?.setValue(1.2, forKey: "inputSaturation") // 增强饱和度
//        colorControlsFilter?.setValue(0.5, forKey: "inputBrightness") // 增加亮度
//        colorControlsFilter?.setValue(1.5, forKey: "inputContrast") // 增加对比度
//        
//        // CIRandomGenerator： 生成一张包含随机像素的图像。这个滤镜通常用于创建纹理或者作为其他特效的输入。
//        let randomGenerator = CIFilter(name: "CIRandomGenerator")
//        let randomImage = randomGenerator?.outputImage
//        
//        // ========== 自带滤镜的调整方法 end ==========
    }
    
    func getExifData(from url: URL?) -> NSDictionary? {
        guard let imageUrl = url else {return nil}
        if let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? NSDictionary,
           let exifDict = imageProperties[kCGImagePropertyExifDictionary as NSString] as? NSDictionary {
//            print(exifDict)
            if let fNumber = exifDict[kCGImagePropertyExifFNumber as String] as? NSNumber {
                // 将光圈值FNumber转换为字符串形式
                let fNumberString = String(format: "F%.1f", fNumber.floatValue)
                print("FNumber (Aperture): \(fNumberString)")

            }
            return exifDict
        }
        
        return nil
    }
    
    func getCameraInfo(from url: URL?) -> CameraInfo {
        guard let imageUrl = url else { return CameraInfo() }
        guard let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as NSDictionary?,
              let exifDict = imageProperties[kCGImagePropertyExifDictionary as NSString] as? NSDictionary,
              let tiffDict = imageProperties[kCGImagePropertyTIFFDictionary as NSString] as? NSDictionary else {
            return CameraInfo()
        }
        
        // 初始化CameraInfo结构体
        var cameraInfo = CameraInfo()
        
        print("====exifDict====", exifDict)
        print("====tiffDict====", tiffDict)
        // 提取并转换所需的信息为字符串
//        cameraInfo.lensMake = exifDict[kCGImagePropertyExifLensMake as String] as? String ?? ""
//        cameraInfo.lensModel = exifDict[kCGImagePropertyExifLensModel as String] as? String ?? ""
//        cameraInfo.lensMake = tiffDict[kCGImagePropertyTIFFMake as String] as? String ?? ""
//        cameraInfo.lensModel = tiffDict[kCGImagePropertyTIFFModel as String] as? String ?? ""
        
        if let lensMake = tiffDict[kCGImagePropertyTIFFMake as String] as? String {
            cameraInfo.lensMake = lensMake.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let lensModel = tiffDict[kCGImagePropertyTIFFModel as String] as? String {
            cameraInfo.lensModel = lensModel.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
//        if let focalLengthNumber = exifDict[kCGImagePropertyExifFocalLength as String] as? NSNumber {
//            cameraInfo.focalLength = "\(focalLengthNumber.stringValue) mm"
//        }
        
        if let focalLengthNumber = exifDict[kCGImagePropertyExifFocalLength as String] as? NSNumber {
            if focalLengthNumber.floatValue > 0 {
                // 如果焦距大于0，保存焦距值，单位是毫米
                cameraInfo.focalLength = "\(focalLengthNumber.stringValue) mm"
            } else {
                // 如果焦距为0，将其作为空字符串处理
                cameraInfo.focalLength = ""
            }
        }
        if let apertureNumber = exifDict[kCGImagePropertyExifFNumber as String] as? NSNumber {
            cameraInfo.aperture = "F/\(apertureNumber.stringValue)"
        }
        if let shutterSpeedValue = exifDict[kCGImagePropertyExifExposureTime as String] as? Double {
            
           
            
            if shutterSpeedValue >= 1 {
                cameraInfo.shutterSpeed = "\(Int(shutterSpeedValue))s"
            } else {
                let denominator = lround(1 / shutterSpeedValue)
                cameraInfo.shutterSpeed = "1/\(denominator)s"
            }
//            let shutterSpeedValue = shutterSpeedNumber.floatValue
//            cameraInfo.shutterSpeed = shutterSpeedValue > 1 ? "\(shutterSpeedNumber.stringValue)s" : "1/\(1/shutterSpeedValue)s"
        }
        if let isoArray = exifDict[kCGImagePropertyExifISOSpeedRatings as String] as? [NSNumber], let isoValue = isoArray.first {
            cameraInfo.iso = "ISO \(isoValue.stringValue)"
        }
        cameraInfo.dateTimeOriginal = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String ?? ""
        
        return cameraInfo
    }
    
    func createCombinedImage(from image: NSImage) {
        let cameraInfo = getCameraInfo(from: originalImagePath)
        print("EXIF", cameraInfo)
        

        
        let aspectRatio: CGFloat = 16.0 / 9.0   // 3.0 / 2.0 //
        let originalSize = image.size
        let newHeight = originalSize.height * 1.3  // 40% taller
        let newWidth = newHeight * aspectRatio // width according to the 16:9 aspect ratio
        let cornerRadius = image.size.width > image.size.height ? image.size.width * 0.025 : image.size.height * 0.025
        // Resize original image
        let resizedImage = createRoundedShadowImage(from: image, cornerRadius: cornerRadius, shadowColor: NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9), shadowBlurRadius: 100, shadowOffset: CGSize(width: 0, height: 0))
        let resizedSize = resizedImage.size
//        let resizedImage = image
        
        print("new width: \(newWidth)")
        print("original size: \(originalSize)")
        print("original width: \(originalSize.width)")
        // Create blurred background
        guard let blurredBackground = image.blurred(radius: 200)?.cropped(to: NSSize(width: originalSize.width, height: originalSize.height)) else {
            return
        }

        // 向图片的下方添加cameraInfo信息
        let infoTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: originalSize.height * 0.03, weight: .regular),
            .obliqueness: 0.1 // 这里可以调整数值来增加或减少斜体的倾斜度
        ]

        let lensInfoTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: originalSize.height * 0.04, weight: .bold)
        ]

        let lensMakeString = NSAttributedString(string: cameraInfo.lensModel, attributes: lensInfoTextAttributes)
        let infoString = NSAttributedString(string: "\(cameraInfo.shutterSpeed)  \(cameraInfo.iso)  \(cameraInfo.aperture)  \(cameraInfo.focalLength)", attributes: infoTextAttributes)

        let textHeight = lensMakeString.size().height + infoString.size().height
        let imageWidth = resizedImage.size.width
        let imageHeight = resizedImage.size.height
        // 调整原图上移位置，为文字信息留出空间
        let imageOffset = originalSize.height * 0.05 // 10 points for padding

        // 重新计算finalImage的高度来容纳文字信息
        let finalHeightWithText = newHeight + imageOffset

        
        // ========== Method 1 ==========
//        // Start drawing context
//        let finalSize = NSSize(width: newWidth, height: newHeight)
//        let finalImage = NSImage(size: finalSize)
//
//        finalImage.lockFocus()
//
//        // Draw the blurred background
//        blurredBackground.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight))
//
//        // Calculate resized image position
//        let resizedPosition = CGPoint(x: (newWidth - resizedImage.size.width) / 2, y: (newHeight - resizedImage.size.height) / 2)
//
//        // Draw the resized image on top of the blurred background
//        resizedImage.draw(at: resizedPosition, from: NSRect(origin: .zero, size: resizedImage.size), operation: .sourceOver, fraction: 1.0)
//
//        finalImage.unlockFocus()
//        print("final image size: \(finalImage.size)")
//
//        combinedImage = finalImage
        
        // ========== Method 2 ==========
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(newWidth),
            pixelsHigh: Int(newHeight),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep!)

        // Draw the blurred image as background
        blurredBackground.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight))

        // Draw the original image in the center of the blurred background
//        resizedImage.draw(in: NSRect(x: (newWidth - resizedSize.width) / 2, y: (newHeight - resizedSize.height) / 2, width: resizedSize.width, height: resizedSize.height), from: NSRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height), operation: .sourceOver, fraction: 1.0)
        
        // Draw the original image in the center of the blurred background, adjusted upwards for text
        resizedImage.draw(in: NSRect(x: (newWidth - imageWidth) / 2, y: (newHeight - imageHeight) / 2 + imageOffset, width: imageWidth, height: imageHeight), from: NSRect(x: 0, y: 0, width: imageWidth, height: imageHeight), operation: .sourceOver, fraction: 1.0)

        // Draw the rest of the camera info string
        infoString.draw(at: CGPoint(x: (newWidth - infoString.size().width) / 2, y: originalSize.height * 0.05))
        
        print("lensMakeString: \(lensMakeString)")
        lensMakeString.draw(at: CGPoint(x: (newWidth - lensMakeString.size().width) / 2, y: originalSize.height * 0.06 + infoString.size().height))


        
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
//            guard let imageData = saveImage.tiffRepresentation,
//                  let fileURL = getSaveURL() else { return }
            
            // 假定 image 是你要设定 DPI 的 NSImage 实例
            guard let imageData = saveImage.tiffRepresentation else {
                print("Failed to get TIFF representation of the image")
                return
            }

            guard let imageRep = NSBitmapImageRep(data: imageData) else {
                print("Failed to create image representation")
                return
            }
            
            // 设定目标 DPI 值
            let targetDPI: CGFloat = 72.0 // 或你所需的任何 DPI 值
            let pixelsWide = imageRep.pixelsWide
            let pixelsHigh = imageRep.pixelsHigh
            
            // 通过改变 size 属性来设定实际 DPI，而不改变像素维度
            imageRep.size = NSSize(width: CGFloat(pixelsWide) / targetDPI,
                                   height: CGFloat(pixelsHigh) / targetDPI)
            
            guard let fileURL = getSaveURL() else { return }

            // properties: [.compressionFactor: 0.9]
            // properties: [:]
            if let dataWithDPI = imageRep.representation(using: .jpeg, properties: [.compressionFactor: 1]) {
                try? dataWithDPI.write(to: fileURL)
                print("Image saved with \(targetDPI) DPI")
            }
            
//            do {
//                try imageData.write(to: fileURL)
//                print("Image saved to \(fileURL.path)")
//            } catch {
//                print("Error saving image: \(error)")
//            }
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
        panel.allowedFileTypes = ["jpg", "png"]
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
