//
//  MocaaPhotoApp.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/2/19.
//

import SwiftUI
import SwiftData


@main
struct MocaaPhotoApp: App {

    @StateObject private var viewModel = AppViewModel()
    // 创建ImageStore的实例
    var imageStore = ImageStore()
    
    var body: some Scene {
        WindowGroup {
            HStack {
                MocaaView()
                    .environmentObject(viewModel)
                    .environmentObject(imageStore)
                SidePannel()
                    .environmentObject(imageStore)
            }
            
        }
        .commands {
            CommandMenu("File") {
                Button("Save") {
                    // 这里调用你的保存逻辑
//                    saveAction()
                    viewModel.triggerSave()
                }
                .keyboardShortcut("s", modifiers: .command) // 添加快捷键 Command + S
            }
        }
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
