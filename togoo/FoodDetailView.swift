//
//  FoodDetailView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct FoodDetailView: View {
    let foodItem: FoodItem
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedCheckoutItem: FoodItem? = nil

    private var cartRef: DatabaseReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference(withPath: "cart/\(uid)")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Food image
                AsyncImage(url: URL(string: foodItem.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 220)
                .clipped()
                .cornerRadius(10)

                // Food name
                Text(foodItem.id)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                // Description
                Text(foodItem.description)
                    .font(.body)
                    .foregroundColor(.gray)

                // Price
                Text(String(format: "$%.2f", foodItem.price))
                    .font(.headline)
                    .foregroundColor(Color(hex: "F18D34"))

                // Action buttons
                HStack(spacing: 20) {
                    Button(action: addToCart) {
                        HStack {
                            Image("ic_add_to_cart")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Add to Cart")
                                .font(.system(size: 14))
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(hex: "F18D34"))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        selectedCheckoutItem = foodItem
                    }) {
                        HStack {
                            Image("ic_buy")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Buy Now")
                                .font(.system(size: 14))
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(hex: "F18D34"))
                        .cornerRadius(10)
                    }
                }

                Spacer()

                // ✅ NavigationLink using item binding
                NavigationLink(
                    destination: selectedCheckoutItem.map {
                        CheckoutView(checkoutItems: [
                            CartItem(
                                foodId: $0.id,
                                foodDescription: $0.description,
                                foodImage: $0.imageUrl,
                                foodPrice: $0.price,
                                quantity: 1
                            )
                        ])
                    },
                    isActive: Binding(
                        get: { selectedCheckoutItem != nil },
                        set: { if !$0 { selectedCheckoutItem = nil } }
                    )
                ) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Food Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "F18D34"))
                    }
                }
            }
        }
    }

    private func addToCart() {
        guard let ref = cartRef else { return }
        let newItemRef = ref.childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": foodItem.id,
            "foodDescription": foodItem.description,
            "foodImage": foodItem.imageUrl,
            "foodPrice": foodItem.price,
            "quantity": 1,
            "cartItemId": newItemRef.key ?? ""
        ]
        newItemRef.setValue(cartItem) { error, _ in
            if error == nil {
                print("✅ Added to Cart!")
            } else {
                print("❌ Failed to add to Cart: \(error?.localizedDescription ?? "")")
            }
        }
    }
}

#Preview {
    FoodDetailView(
        foodItem: FoodItem(
            id: "Cheeseburger",
            description: "Juicy grilled burger",
            imageUrl: "https://example.com/burger.jpg",
            price: 7.99
        )
    )
}
