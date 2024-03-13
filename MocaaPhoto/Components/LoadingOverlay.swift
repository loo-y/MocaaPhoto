import SwiftUI

struct LoadingOverlay: View {
    @State var isAnimating: Bool = true
    
    var body: some View {
        ZStack {
            // Use a semi-transparent overlay to mimic inactive app interface
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all) // This makes the overlay extend to the whole window
            
            // Create the loading spinner
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5, anchor: .center) // Increase the size of spinner
            
            // Optionally you could create a custom skeuomorphic spinner design
            // instead of using the built-in ProgressView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Cover the whole screen
    }
}

#Preview {
    LoadingOverlay()
}
