//
//  MocaaPhotoApp.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/2/19.
//

import SwiftUI

@main
struct MocaaPhotoApp: App {

    @StateObject private var viewModel = AppViewModel()
    // 创建ImageStore的实例
    var imageStore = ImageStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
//            .onAppear {
//                // 设置标题栏颜色的逻辑
//                // 获取当前的NSWindow对象
//                if let window = NSApplication.shared.windows.first {
//                    // 创建一个新的NSView作为标题栏背景并设置颜色
//                    let titlebarView = NSView(frame: window.frame)
//                    titlebarView.wantsLayer = true
//                    titlebarView.layer?.backgroundColor = NSColor.white.cgColor
//
//                    // 将这个新视图添加到window的titlebar上
//                    window.titlebarAppearsTransparent = true
//                    window.standardWindowButton(.closeButton)?.superview?.addSubview(titlebarView, positioned: .below, relativeTo: window.standardWindowButton(.closeButton))
//                }
//            }
            .configureWindow(color: NSColor.white)
            
//                .frame(width: 300, height: 250)
//                .fixedSize() // 固定窗口尺寸
                
//            HStack {
//                MocaaView()
//                    .environmentObject(viewModel)
//                    .environmentObject(imageStore)
//                SidePannel()
//                    .environmentObject(imageStore)
//            }
            
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
//        .windowStyle(HiddenTitleBarWindowStyle())
//        .windowStyle(DefaultWindowStyle()) // 使用默认窗口样式
//        .commands {
//            CommandMenu("File") {
//                Button("Save") {
//                    // 这里调用你的保存逻辑
////                    saveAction()
//                    viewModel.triggerSave()
//                }
//                .keyboardShortcut("s", modifiers: .command) // 添加快捷键 Command + S
//            }
//        }
    }
    
    func saveAction() {
        
    }
}


class AppViewModel: ObservableObject {
    @Published var triggerSaveAction: Bool = false

    func triggerSave() {
        triggerSaveAction.toggle()
    }
}

// 创建一个类来存储图像，它遵循ObservableObject协议
class ImageStore: ObservableObject {
    // 使用@Published，这样每当image发生变化时，所有使用此对象的视图都会得到更新
    @Published var currentImage: NSImage?

    // 初始化器，你可以进行一些设置或者从某个资源中加载图片
//    init() {
//        // 假设我们有一个名为"example-image"的图像在Assets.xcassets里
//        image = Image("example-image")
//    }
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
    
    func configureWindow(color: NSColor, width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self.onAppear {
            print("onAppear===>", color.cgColor)
            if let window = NSApplication.shared.windows.first,
               let contentView = window.contentView?.superview {
                // 创建一个新的NSView作为标题栏背景并设置颜色
                let titlebarView = NSView(frame: contentView.bounds)
                titlebarView.wantsLayer = true
                titlebarView.layer?.backgroundColor = color.cgColor

                // 将这个新视图添加到window的titlebar上
                window.titlebarAppearsTransparent = true
                contentView.addSubview(titlebarView, positioned: .below, relativeTo: contentView)
                
                if let width = width, let height = height {
                    window.setContentSize(NSSize(width: width, height: height))
                    // Optional: center the window
                    window.center()
                }
            }
        }
    }
}
