//
//  CartView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//



import SwiftUI
import FirebaseAuth
import FirebaseDatabase

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

    @State private var navigateToCheckout = false
    @State private var selectedRestaurant: Restaurant?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: foodItem.imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)

            Text(foodItem.id).font(.headline)
            Text(foodItem.description).font(.subheadline).foregroundColor(.gray)
            Text("$\(foodItem.price, specifier: "%.2f")")
                .font(.subheadline).foregroundColor(.orange)

            HStack(spacing: 12) {
                Button(action: {
                    addToCart(food: foodItem)
                }) {
                    Image("ic_add_to_cart")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .padding(4)
                }

                NavigationLink(
                    destination: checkoutDestination,
                    isActive: $navigateToCheckout
                ) {
                    Button {
                        buyNow(food: foodItem)
                    } label: {
                        Image("ic_buy")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .padding(4)
                    }
                }
            }

            if showError {
                Text(errorMessage).foregroundColor(.red).font(.footnote)
            }
        }
        .padding()
        .onTapGesture {
            onFoodClick(foodItem)
        }
    }

    // MARK: - Destination View
    private var checkoutDestination: some View {
        if let restaurant = selectedRestaurant {
            return AnyView(
                CheckoutView(checkoutItems: [
                    CartItem(
                        foodId: foodItem.id,
                        foodDescription: foodItem.description,
                        foodImage: foodItem.imageURL,
                        restaurantId: restaurant.id,
                        foodPrice: foodItem.price,
                        quantity: 1
                    )
                ])
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: - Cart Management
    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showError(message: "Please log in to add items to cart.")
            return
        }

        fetchRestaurant(for: food.restaurantId) { restaurant in
            guard let restaurant = restaurant else {
                showError(message: "Restaurant info missing")
                return
            }

            RestaurantHelper.setCurrentRestaurant(restaurant)

            let cartItem: [String: Any] = [
                "foodId": food.id,
                "foodDescription": food.description,
                "foodImage": food.imageURL,
                "foodPrice": food.price,
                "quantity": 1,
                "restaurantId": restaurant.id
            ]

            let cartRef = Database.database().reference(withPath: "cart/\(uid)").childByAutoId()
            cartRef.setValue(cartItem) { error, _ in
                if let error = error {
                    showError(message: "Failed to add to cart: \(error.localizedDescription)")
                } else {
                    print("✅ Added to cart: \(food.id)")
                }
            }
        }
    }

    private func buyNow(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showError(message: "Please log in to buy items.")
            return
        }

        fetchRestaurant(for: food.restaurantId) { restaurant in
            guard let restaurant = restaurant else {
                showError(message: "Restaurant info missing.")
                return
            }

            RestaurantHelper.setCurrentRestaurant(restaurant)
            selectedRestaurant = restaurant
            navigateToCheckout = true
        }
    }

    private func fetchRestaurant(for restaurantId: String, completion: @escaping (Restaurant?) -> Void) {
        let ref = Database.database().reference(withPath: "restaurant/\(restaurantId)")
        ref.getData { error, snapshot in
            if let data = snapshot?.value as? [String: Any] {
                let restaurant = Restaurant(dict: data, id: restaurantId)
                completion(restaurant)
            } else {
                completion(nil)
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
