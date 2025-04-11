//
//  FeaturedCategoryView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct FeaturedCategoryView: View {
    let selectedCategory: String
    @Environment(\.dismiss) private var dismiss

    @State private var foodItems: [FoodItem] = []
    @State private var showNoItemsAlert: Bool = false

    @State private var navigateToDestination = false
    @State private var destinationView: AnyView? = nil

    private var dbRef: DatabaseReference {
        Database.database().reference(withPath: "restaurant")
    }

    let primaryColor = Color(hex: "F18D34")
    let darkGray = Color(hex: "757575")
    let lightGray = Color(hex: "F5F5F5")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Text("Featured Category")
                        .foregroundColor(.white)
                        .font(.headline)

                    Spacer()
                    Spacer().frame(width: 60)
                }
                .padding()
                .background(primaryColor)

                if foodItems.isEmpty {
                    Spacer()
                    Text("No items found for \(selectedCategory)")
                        .font(.title3)
                        .foregroundColor(darkGray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(foodItems) { food in
                                VStack(alignment: .leading, spacing: 10) {
                                    Button {
                                        fetchRestaurant(for: food.restaurantId) { restaurant in
                                            if let restaurant = restaurant {
                                                destinationView = AnyView(FoodDetailView(foodItem: food, restaurant: restaurant))
                                                navigateToDestination = true
                                            }
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 10) {
                                            AsyncImage(url: URL(string: food.imageURL)) { image in
                                                image.resizable().scaledToFill()
                                            } placeholder: {
                                                Color.gray
                                            }
                                            .frame(height: 150)
                                            .clipped()
                                            .cornerRadius(10)

                                            Text(food.id)
                                                .font(.headline)
                                                .foregroundColor(.black)

                                            Text(food.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    HStack {
                                        Text("$\(food.price, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)

                                        Spacer()

                                        Button {
                                            fetchRestaurant(for: food.restaurantId) { restaurant in
                                                if let restaurant = restaurant {
                                                    destinationView = AnyView(CheckoutView(checkoutItems: [CartItem(
                                                        foodId: food.id,
                                                        foodDescription: food.description,
                                                        foodImage: food.imageURL,
                                                        restaurantId: food.restaurantId,
                                                        foodPrice: food.price,
                                                        quantity: 1
                                                    )]))
                                                    navigateToDestination = true
                                                }
                                            }
                                        } label: {
                                            Image("ic_buy")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }

                                        Button {
                                            addToCart(food: food)
                                        } label: {
                                            Image("ic_add_to_cart")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                NavigationLink(
                    destination: destinationView,
                    isActive: $navigateToDestination
                ) {
                    EmptyView()
                }
            }
            .background(lightGray)
            .navigationBarBackButtonHidden(true)
            .alert("No Items", isPresented: $showNoItemsAlert) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("No items found for \(selectedCategory).")
            }
            .onAppear {
                fetchCategoryItems(for: selectedCategory)
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
                print("❌ Failed to fetch restaurant for ID: \(restaurantId)")
                completion(nil)
            }
        }
    }

    private func fetchCategoryItems(for category: String) {
        let restaurantNames = getRestaurantsForCategory(category: category)
        var items: [FoodItem] = []

        dbRef.observeSingleEvent(of: .value) { snapshot in
            for case let restaurantSnap as DataSnapshot in snapshot.children {
                if let restaurantName = restaurantSnap.childSnapshot(forPath: "name").value as? String,
                   restaurantNames.contains(restaurantName) {
                    let restaurantId = restaurantSnap.key
                    let menuSnapshot = restaurantSnap.childSnapshot(forPath: "menu").childSnapshot(forPath: category)

                    for case let foodSnap as DataSnapshot in menuSnapshot.children {
                        let id = foodSnap.key
                        let description = foodSnap.childSnapshot(forPath: "description").value as? String
                        let imageUrl = foodSnap.childSnapshot(forPath: "imageURL").value as? String
                        let price = foodSnap.childSnapshot(forPath: "price").value as? Double
                        if let description, let imageUrl, let price {
                            items.append(FoodItem(id: id, description: description, imageURL: imageUrl, restaurantId: restaurantId, price: price))
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                if items.isEmpty {
                    showNoItemsAlert = true
                } else {
                    foodItems = items
                }
            }
        }
    }

    private func addToCart(food: FoodItem) {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user.")
            return
        }
        let cartRef = Database.database().reference(withPath: "cart").child(currentUser.uid).childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageURL,
            "restaurantId": food.restaurantId,
            "foodPrice": food.price,
            "quantity": 1
        ]
        cartRef.setValue(cartItem) { error, _ in
            if let error = error {
                print("❌ Failed to add to cart: \(error.localizedDescription)")
            } else {
                print("✅ Added \(food.id) to cart")
            }
        }
    }

    private func getRestaurantsForCategory(category: String) -> [String] {
        switch category {
        case "Pizza", "Pasta":
            return ["American Cuisine", "Italian Cuisine"]
        case "Burgers", "Seafood", "Salads":
            return ["American Cuisine"]
        case "Sushi":
            return ["Japanese Cuisine", "American Cuisine"]
        case "Tacos":
            return ["Mexican Cuisine"]
        case "Desserts":
            return ["Canadian Dishes"]
        default:
            return []
        }
    }
}


#Preview {
    FeaturedCategoryView(selectedCategory: "Pizza")
}
