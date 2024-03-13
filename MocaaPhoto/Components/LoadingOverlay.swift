import SwiftUI

struct LoadingOverlay: View {
    @State var isAnimating: Bool = true
    
    var body: some View {
//        ZStack {
//            // Use a semi-transparent overlay to mimic inactive app interface
//            Color.black.opacity(0.4)
//                .edgesIgnoringSafeArea(.all) // This makes the overlay extend to the whole window
//            
//            // Create the loading spinner
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                .scaleEffect(1.5, anchor: .center) // Increase the size of spinner
//            
//            // Optionally you could create a custom skeuomorphic spinner design
//            // instead of using the built-in ProgressView
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Cover the whole screen
        

        ZStack {
            Color.black.opacity(0.5) // 半透明黑色背景
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView() // 内置的loading动画视图
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0) // 放大loading动画
                    
                Text("Loading...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
        }

    }
}

#Preview {
    LoadingOverlay()
}
