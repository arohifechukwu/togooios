//
//  AdminBottomNavItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


import SwiftUI

struct AdminBottomNavItem: View {
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
                    .foregroundColor(isSelected ? primaryColor : .gray)
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - Color Palette
    private var primaryColor: Color {
        return Color(hex: "F18D34") // Dark Orange
    }
}