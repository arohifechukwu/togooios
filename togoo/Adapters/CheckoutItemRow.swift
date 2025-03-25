//
//  CheckoutItemRow 2.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct CheckoutItemRow: View {
    @Binding var cartItem: CartItem
    var onQuantityChanged: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Food Image
            AsyncImage(url: URL(string: cartItem.foodImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image("ic_food_placeholder")
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(6)

            // Name and Price
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.foodDescription)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Text(String(format: "$%.2f", cartItem.foodPrice))
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Quantity Controls
            HStack(spacing: 6) {
                Button(action: {
                    if cartItem.quantity > 1 {
                        cartItem.quantity -= 1
                        onQuantityChanged()
                    }
                }) {
                    Text("-")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }

                Text("\(cartItem.quantity)")
                    .font(.system(size: 18))
                    .frame(width: 36, height: 36)
                    .multilineTextAlignment(.center)

                Button(action: {
                    cartItem.quantity += 1
                    onQuantityChanged()
                }) {
                    Text("+")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding(10)
        .background(Color.white)
    }
}

