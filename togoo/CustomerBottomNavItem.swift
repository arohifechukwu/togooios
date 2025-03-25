//
//  CustomerBottomNavItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct CustomerBottomNavItem: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .opacity(isSelected ? 1.0 : 0.6)

                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? primaryColor : darkGray)
            }
            .padding(.top, 6)
        }
    }

    // MARK: - Color Palette
    private var primaryColor: Color {
        Color(hex: "F18D34") // Selected item color
    }

    private var darkGray: Color {
        Color(hex: "757575") // Unselected item color
    }
}
struct CustomerBottomNavItem_Previews: PreviewProvider {
    static var previews: some View {
        CustomerBottomNavItem(imageName: "ic_home", title: "Home", isSelected: true) {
            print("Home tapped")
        }
        .previewLayout(.sizeThatFits)
    }
}
