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
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("hello MocaaPhoto")
            
            VStack(content: {
                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
            })
            .padding(.all)
        }
        .padding(.all, 10.0)
    }
}

#Preview {
    MocaaAddView()
}
