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
    @Environment(\.presentationMode) private var presentationMode
    @State private var foodItems: [FoodItem] = []
    @State private var showNoItemsAlert: Bool = false

    @State private var selectedFoodItem: FoodItem? = nil
    @State private var selectedCheckoutItem: FoodItem? = nil

    private var dbRef: DatabaseReference {
        Database.database().reference(withPath: "restaurant")
    }

    let primaryColor = Color(hex: "F18D34")
    let darkGray = Color(hex: "757575")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(primaryColor)

                    Spacer()

                    Text(selectedCategory)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(8)
                        .cornerRadius(6)

                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding()

                // Content
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
                                    Button(action: {
                                        selectedFoodItem = food
                                    }) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            AsyncImage(url: URL(string: food.imageUrl)) { image in
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

                                        Button(action: {
                                            selectedCheckoutItem = food
                                        }) {
                                            HStack {
                                                Image("ic_buy")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("Buy Now")
                                            }
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(primaryColor)
                                            .cornerRadius(8)
                                        }

                                        Button(action: {
                                            addToCart(food: food)
                                        }) {
                                            HStack {
                                                Image("ic_add_to_cart")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("Add to Cart")
                                            }
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(primaryColor)
                                            .cornerRadius(8)
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

                // Navigation to FoodDetailView
                NavigationLink(destination: selectedFoodItem.map { FoodDetailView(foodItem: $0) }, isActive: Binding(
                    get: { selectedFoodItem != nil },
                    set: { if !$0 { selectedFoodItem = nil } }
                )) {
                    EmptyView()
                }

                // Navigation to CheckoutView
                NavigationLink(destination: selectedCheckoutItem.map {
                    CheckoutView(checkoutItems: [
                        CartItem(
                            foodId: $0.id,
                            foodDescription: $0.description,
                            foodImage: $0.imageUrl,
                            foodPrice: $0.price,
                            quantity: 1
                        )
                    ])
                }, isActive: Binding(
                    get: { selectedCheckoutItem != nil },
                    set: { if !$0 { selectedCheckoutItem = nil } }
                )) {
                    EmptyView()
                }
            }
            .background(Color(hex: "F5F5F5"))
            .navigationBarBackButtonHidden(true)
            .alert("No Items", isPresented: $showNoItemsAlert) {
                Button("OK", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("No items found for \(selectedCategory).")
            }
            .onAppear {
                fetchCategoryItems(for: selectedCategory)
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
                    let menuSnapshot = restaurantSnap.childSnapshot(forPath: "menu").childSnapshot(forPath: category)
                    for case let foodSnap as DataSnapshot in menuSnapshot.children {
                        let id = foodSnap.key
                        let description = foodSnap.childSnapshot(forPath: "description").value as? String
                        let imageUrl = foodSnap.childSnapshot(forPath: "imageURL").value as? String
                        let price = foodSnap.childSnapshot(forPath: "price").value as? Double
                        if let description = description, let imageUrl = imageUrl, let price = price {
                            items.append(FoodItem(id: id, description: description, imageUrl: imageUrl, price: price))
                        }
                    }
                }
            }
            if items.isEmpty {
                showNoItemsAlert = true
            } else {
                foodItems = items
            }
        }
    }

    private func addToCart(food: FoodItem) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let cartRef = Database.database().reference(withPath: "cart").child(currentUser.uid)
        let newItemRef = cartRef.childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageUrl,
            "foodPrice": food.price,
            "quantity": 1
        ]
        newItemRef.setValue(cartItem) { error, _ in
            if error == nil {
                print("✅ Added to Cart")
            } else {
                print("❌ Error: \(error?.localizedDescription ?? "Unknown error")")
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

struct FeaturedCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedCategoryView(selectedCategory: "Pizza")
    }
}
