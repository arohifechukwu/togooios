//
//  FoodItemRowView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct FoodItemRowView: View {
    // Properties for the food item
    var foodImageURL: String
    var foodName: String
    var foodPrice: String
    // Callback when delete is tapped
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Food image using AsyncImage (iOS 15+)
            AsyncImage(url: URL(string: foodImageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                } else if phase.error != nil {
                    // Error placeholder
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                } else {
                    // While loading
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            }
            
            // Vertical stack for food name and price
            VStack(alignment: .leading, spacing: 4) {
                Text(foodName)
                    .font(.system(size: 18, weight: .bold))
                Text(foodPrice)
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Delete button
            Button(action: {
                onDelete()
            }) {
                Text("Delete")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color.red)
                    .cornerRadius(5)
            }
        }
        .padding(10)
        .background(Color.white)
    }
}

struct FoodItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        FoodItemRowView(foodImageURL: "https://via.placeholder.com/80",
                        foodName: "Pizza Margherita",
                        foodPrice: "$9.99",
                        onDelete: {
                            // Preview delete action
                            print("Delete tapped")
                        })
            .previewLayout(.sizeThatFits)
            .padding()
    }
}