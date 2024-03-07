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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            MocaaView()
                .environmentObject(viewModel)
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
        .modelContainer(sharedModelContainer)
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
