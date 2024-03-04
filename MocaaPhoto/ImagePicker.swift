

import SwiftUI
import AppKit

struct ImagePicker: NSViewControllerRepresentable {
    @Binding var image: NSImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSViewController(context: Context) -> NSViewController {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.png, .jpeg, .tiff]
        openPanel.beginSheetModal(for: NSApp.keyWindow!) { result in
            if result == .OK, let url = openPanel.url {
                context.coordinator.loadImage(url: url)
            }
        }
        return NSViewController()
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}

    class Coordinator: NSObject {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func loadImage(url: URL) {
            if let image = NSImage(contentsOf: url) {
                parent.image = image
            }
        }
    }
}
