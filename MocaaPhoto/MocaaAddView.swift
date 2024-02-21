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
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [NSImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else { return }
        
        Task {
//            if let data = try? await selection.loadTransferable(type: Data.self) {
//                if let uiImage = NSImage(data: data){
//                    selectedImage = uiImage
//                    return;
//                }
//            }
            
            do {
                let data = try? await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = NSImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]?){
        guard let selections else { return }
        
        Task {
            var images: [NSImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = NSImage(data: data){
                        selectedImage = uiImage
                        return;
                    }
                }
            }
        }
    }
}

struct MocaaAddView: View {
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Text("hello MocaaPhoto")
            
            if let image = viewModel.selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Pick a Photo")
                    .foregroundColor(.blue)
            }
        }
        .padding(.all, 10.0)
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    MocaaAddView()
}
