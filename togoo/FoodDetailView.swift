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
    let restaurant: Restaurant
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
                AsyncImage(url: URL(string: foodItem.imageURL)) { image in
                    image.resizable().scaledToFill()
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
                        fetchRestaurant(for: foodItem.restaurantId) { fetchedRestaurant in
                            if let fetchedRestaurant = fetchedRestaurant {
                                RestaurantHelper.setCurrentRestaurant(fetchedRestaurant)
                                selectedCheckoutItem = foodItem
                            } else {
                                print("❌ Failed to fetch restaurant info")
                            }
                        }
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

                NavigationLink(
                    destination: selectedCheckoutItem.map {
                        CheckoutView(checkoutItems: [
                            CartItem(
                                foodId: $0.id,
                                foodDescription: $0.description,
                                foodImage: $0.imageURL,
                                restaurantId: $0.restaurantId,
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
            .onAppear {
                RestaurantHelper.setCurrentRestaurant(restaurant)
            }
        }
    }

    private func addToCart() {
        guard let ref = cartRef else { return }
        let newItemRef = ref.childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": foodItem.id,
            "foodDescription": foodItem.description,
            "foodImage": foodItem.imageURL,
            "foodPrice": foodItem.price,
            "quantity": 1,
            "cartItemId": newItemRef.key ?? "",
            "restaurantId": foodItem.restaurantId
        ]
        newItemRef.setValue(cartItem) { error, _ in
            if error == nil {
                print("✅ Added to Cart!")
            } else {
                print("❌ Failed to add to Cart: \(error?.localizedDescription ?? "")")
            }
        }
    }

    private func fetchRestaurant(for restaurantId: String, completion: @escaping (Restaurant?) -> Void) {
        let ref = Database.database().reference().child("restaurant").child(restaurantId)
        ref.getData { error, snapshot in
            if let data = snapshot?.value as? [String: Any],
               let restaurant = Restaurant(dict: data, id: restaurantId) {
                completion(restaurant)
            } else {
                completion(nil)
            }
        }
    }
}


#Preview {
    let mockRestaurant = Restaurant(
        id: "res123",
        name: "Mock Restaurant",
        address: "123 Mock St",
        imageURL: "https://example.com/mock.jpg",
        location: nil,
        operatingHours: [:],
        rating: 4.5,
        distanceKm: 1.2,
        etaMinutes: 10
    )

    let mockFood = FoodItem(
        id: "Cheeseburger",
        description: "Juicy grilled burger",
        imageURL: "https://example.com/burger.jpg",
        restaurantId: "res123",
        price: 7.99
    )

    return FoodDetailView(foodItem: mockFood, restaurant: mockRestaurant)
}
