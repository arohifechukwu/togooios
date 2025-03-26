//
//  ViewAllView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-26.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ViewAllView: View {
    var results: [FoodItem]
    var keyword: String

    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedCheckoutItem: CartItem?
    @State private var selectedFoodDetailItem: FoodItem?
    @State private var navigateToCheckout = false
    @State private var navigateToFoodDetail = false

    let primaryColor = Color(hex: "F18D34")

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(results) { item in
                        Button(action: {
                            selectedFoodDetailItem = item
                            navigateToFoodDetail = true
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: URL(string: item.imageUrl)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(8)

                                Text(item.id)
                                    .font(.headline)
                                    .foregroundColor(.black)

                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)

                                HStack(spacing: 12) {
                                    Text(String(format: "$%.2f", item.price))
                                        .fontWeight(.bold)

                                    Spacer()

                                    // Buy Now
                                    Button {
                                        selectedCheckoutItem = CartItem(
                                            foodId: item.id,
                                            foodDescription: item.description,
                                            foodImage: item.imageUrl,
                                            foodPrice: item.price,
                                            quantity: 1
                                        )
                                        navigateToCheckout = true
                                    } label: {
                                        Image("ic_buy")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    }

                                    // Add to Cart
                                    Button {
                                        addToCart(food: item)
                                    } label: {
                                        Image("ic_add_to_cart")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                }
            }
            // ✅ Navigate to FoodDetailView
            .navigationDestination(isPresented: $navigateToFoodDetail) {
                if let food = selectedFoodDetailItem {
                    FoodDetailView(foodItem: food)
                }
            }
            // ✅ Navigate to CheckoutView
            .navigationDestination(isPresented: $navigateToCheckout) {
                if let item = selectedCheckoutItem {
                    CheckoutView(checkoutItems: [item])
                }
            }
        }
    }

    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference(withPath: "cart").child(uid).childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageUrl,
            "foodPrice": food.price,
            "quantity": 1,
            "cartItemId": ref.key ?? ""
        ]

        ref.setValue(cartItem) { error, _ in
            if let error = error {
                print("❌ Failed to add to cart: \(error.localizedDescription)")
            } else {
                print("✅ Added \(food.id) to cart")
            }
        }
    }
}

struct ViewAllView_Previews: PreviewProvider {
    static var previews: some View {
        ViewAllView(
            results: [
                FoodItem(id: "Burger", description: "Delicious beef burger", imageUrl: "https://example.com/burger.jpg", price: 7.99),
                FoodItem(id: "Sushi", description: "Fresh salmon sushi", imageUrl: "https://example.com/sushi.jpg", price: 12.99)
            ],
            keyword: "Burger"
        )
    }
}
