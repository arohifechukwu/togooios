//
//  CartItemRowView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI
import FirebaseDatabase

struct CartItemRowView: View {
    var cartItem: CartItem
    var cartRef: DatabaseReference
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AsyncImage(url: URL(string: cartItem.foodImage)) { image in
                image.resizable()
            } placeholder: {
                Image("ic_food_placeholder")
                    .resizable()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(cartItem.foodDescription)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(String(format: "$%.2f", cartItem.foodPrice))
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Spacer()

            Button(action: {
                deleteItem()
            }) {
                Text("Delete")
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    private func deleteItem() {
        guard let key = cartItem.cartItemId else {
            print("❌ Item key not found!")
            return
        }

        cartRef.child(key).removeValue { error, _ in
            if let error = error {
                print("❌ Failed to remove item: \(error.localizedDescription)")
            } else {
                print("✅ Item removed successfully!")
                onDelete()
            }
        }
    }
}