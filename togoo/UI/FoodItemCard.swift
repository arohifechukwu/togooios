//
//  FoodItemCard.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct FoodItemCard: View {
    var foodName: String
    var foodDescription: String
    var foodPrice: Double
    var foodImageURL: String?
    var onAddToCart: () -> Void
    var onBuyNow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Food Image
            AsyncImage(url: URL(string: foodImageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100) // 🔸 Smaller height
                    .clipped()
                    .cornerRadius(10)
            } placeholder: {
                Image("ic_food_placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .clipped()
                    .cornerRadius(8)
            }

            // Food Name
            Text(foodName)
                .font(.system(size: 14, weight: .semibold)) // 🔸 Smaller font
                .foregroundColor(.black)
                .lineLimit(1)

            // Description
            Text(foodDescription)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)

            // Price and buttons
            HStack(spacing: 6) {
                Text(String(format: "$%.2f", foodPrice))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: onBuyNow) {
                    Image("ic_buy")
                        .resizable()
                        .frame(width: 18, height: 18)
                }

                Button(action: onAddToCart) {
                    Image("ic_add_to_cart")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
        }
        .padding(10)
        .frame(width: 240) // 🔸 Constrained card width
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.vertical, 4)
    }
}


struct FoodItemCard_Previews: PreviewProvider {
    static var previews: some View {
        FoodItemCard(
            foodName: "Pizza",
            foodDescription: "A delicious pizza made with fresh ingredients.",
            foodPrice: 9.99,
            foodImageURL: "https://example.com/pizza.jpg",
            onAddToCart: {
                print("Add to Cart tapped")
            },
            onBuyNow: {
                print("Buy Now tapped")
            }
        )
        .previewLayout(.sizeThatFits)
    }
}
