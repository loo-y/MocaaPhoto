//
//  SidePannel.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI
import AppKit

struct SidePannel: View {
    
    func snapshotView<T: View>(_ view: T) -> NSImage? {
        // 创建一个宿主控制器
        let hostingView = NSHostingView(rootView: view)

        // 更新视图的大小和位置
        hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: 200) // 设置为实际视图的大小
        
        // 保证更新内容
        hostingView.layout()
        
        // 准备在指定区域内创建图片
        let rect = hostingView.bounds
        
        // 创建图片表述
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: rect) else {
            return nil
        }
        
        // 缓存视图的内容到位图图片表述
        hostingView.cacheDisplay(in: rect, to: bitmapRep)
        
        // 创建并返回图像
        let image = NSImage(size: bitmapRep.size)
        image.addRepresentation(bitmapRep)
        return image
    }
    
    
    func saveImage(_ image: NSImage, at url: URL) -> Bool {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return false
        }
        
        do {
            try pngData.write(to: url)
            return true
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return false
        }
    }
    @EnvironmentObject var imageStore: ImageStore
    
    var body: some View {
        VStack {
            Text("SidePannel")
            Button("Export") {
                if let image = snapshotView(MocaaView().environmentObject(imageStore)) {
//                    let desktopDirectoryURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//                    let fileURL = desktopDirectoryURL.appendingPathComponent("snapshot.png")
//                    if saveImage(image, at: fileURL) {
//                        print("Image was successfully saved.")
//                    } else {
//                        print("Failed to save the image.")
//                    }
                    
                    let panel = NSSavePanel()
                    panel.allowedFileTypes = ["png"]
                    panel.canCreateDirectories = true
                    panel.isExtensionHidden = false
                    panel.title = "Save Your Snapshot"
                    
                    panel.message = "Choose a location to save your snapshot:"
                    panel.nameFieldStringValue = "snapshot.png"

                    // 显示保存面板
                    panel.begin { response in
                        if response == .OK {
                            if let url = panel.url {
                                // 现在我们有了保存文件的权限，继续保存操作
                                if saveImage(image, at: url) {
                                    print("Image was successfully saved.")
                                } else {
                                    print("Failed to save the image.")
                                }
                            }
                        }
                    }
                    

                }
            }
        }
        .frame(width: 300)
    }
}

#Preview {
    SidePannel()
}
