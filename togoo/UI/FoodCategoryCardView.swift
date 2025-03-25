//
//  FoodCategoryCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct FoodCategoryCardView: View {
    var imageName: String = "ic_food_category_placeholder"
    var categoryName: String = "Category"

    var body: some View {
        VStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 46, height: 46) // 🔸 Smaller image
                .clipShape(Circle())

            Text(categoryName)
                .font(.system(size: 9, weight: .semibold)) // 🔸 Smaller font
                .foregroundColor(Color("dark_gray"))
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .padding(6)
        .frame(width: 70) // 🔸 Reduced width
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("primary_variant"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.vertical, 4)
    }
}

struct FoodCategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        FoodCategoryCardView()
            .previewLayout(.sizeThatFits)
    }
}
