//
//  MButton.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/3/12.
//

import SwiftUI

struct MButton: View {
    var text: String
    var action: () -> Void
    var color: Color // 传入颜色以改变button的基本颜色

    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
                .font(.headline)
                .frame(width: 150, height: 50)
                .background(color)
                .cornerRadius(20)
                .shadow(color: color.opacity(0.3), radius: 10, x: 7, y: 7) // Use the color parameter
                .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    MButton(text: "Add Image", action: {
        // Handle the button tap
    }, color: .green)
}
