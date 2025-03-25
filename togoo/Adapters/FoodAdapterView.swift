//
//  FoodAdapterView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct FoodAdapterView: View {
    var foodList: [FoodItem]
    var onFoodClick: (FoodItem) -> Void

    var body: some View {
        List(foodList) { food in
            FoodItemRow(foodItem: food, onFoodClick: onFoodClick)
        }
        .listStyle(PlainListStyle())
    }
}

struct FoodItemRow: View {
    let foodItem: FoodItem
    var onFoodClick: (FoodItem) -> Void

    let primaryColor = Color(hex: "F18D34")
    @State private var navigateToCheckout: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: foodItem.imageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)

            Text(foodItem.id)
                .font(.headline)
                .foregroundColor(.black)

            Text(foodItem.description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("$\(foodItem.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(primaryColor)

            HStack(spacing: 12) {
                // Add to Cart icon
                Button(action: {
                    addToCart(food: foodItem)
                }) {
                    Image("ic_add_to_cart")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .padding(4)
                }

                // Buy Now icon leading to CheckoutView
                NavigationLink(
                    destination: CheckoutView(checkoutItems: [CartItem(
                        foodId: foodItem.id,
                        foodDescription: foodItem.description,
                        foodImage: foodItem.imageUrl,
                        foodPrice: foodItem.price,
                        quantity: 1
                    )]),
                    isActive: $navigateToCheckout
                ) {
                    Button(action: {
                        navigateToCheckout = true
                    }) {
                        Image("ic_buy")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .padding(4)
                    }
                }
            }
        }
        .padding()
        .onTapGesture {
            onFoodClick(foodItem)
        }
    }

    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference(withPath: "cart/\(uid)").childByAutoId()

        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageUrl,
            "foodPrice": food.price,
            "quantity": 1
        ]

        ref.setValue(cartItem) { error, _ in
            if let error = error {
                print("❌ Error adding to cart: \(error.localizedDescription)")
            } else {
                print("✅ Added to cart: \(food.id)")
            }
        }
    }
}
