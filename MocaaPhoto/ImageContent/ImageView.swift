//
//  ImageView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/9.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var viewModel: ImageEditorViewModel
    
    @State private var windowSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer() // 竖直填充
                if let combinedImage = viewModel.combinedImage {
                    Image(nsImage: combinedImage)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer() // 竖直填充
            }
            .onAppear {
                // 当出现时，用实际的大小更新模型
                self.viewModel.updateSnapshotSize(geometry.size)
                print("geometry size: \(geometry.size)")
                print("(geometry.size.width / 16 * 9): \((geometry.size.width / 16 * 9))")
                print("geometry.size.height : \(geometry.size.height)")
            }
            .onChange(of: geometry.size) { _ in
                self.windowSize = geometry.size
            }
            .frame(width: geometry.size.width)
            .frame(height: geometry.size.height)
            .background(Color.black)
        }
//        .scaledToFit()
//        .aspectRatio(contentMode: .fit)
        .frame(minWidth: 700)
        //忽略安全区域，让背景色填满整个屏幕
//        .edgesIgnoringSafeArea(.all)
    }
}
