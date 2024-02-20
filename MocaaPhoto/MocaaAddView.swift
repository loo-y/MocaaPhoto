//
//  MocaaAddView.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/2/20.
//

import SwiftUI
import PhotosUI



@MainActor
final class PhotoPickerViewModel: ObservableObject{
    
    @Published private(set) var selectedImage: NSImage? = nil
}

struct MocaaAddView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MocaaAddView()
}
