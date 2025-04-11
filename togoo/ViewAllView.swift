import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct ViewAllView: View {
    var results: [FoodItem]
    var keyword: String
    var onBuyNow: (CartItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFoodItem: FoodItem?
    @State private var selectedRestaurant: Restaurant?
    @State private var navigateToDetail: Bool = false

    let primaryColor = Color(hex: "F18D34")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔸 Custom Toolbar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }

                    Spacer()

                    Text("Search Results")
                        .font(.headline)
                        .foregroundColor(.black)

                    Spacer().frame(width: 60) // spacing symmetry
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 2)

                Divider()

                // 🔸 Results List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(results) { item in
                            Button(action: {
                                fetchRestaurant(for: item.restaurantId) { restaurant in
                                    self.selectedFoodItem = item
                                    self.selectedRestaurant = restaurant
                                    self.navigateToDetail = true
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    AsyncImage(url: URL(string: item.imageURL)) { image in
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

                                    HStack {
                                        Text(String(format: "$%.2f", item.price))
                                            .font(.subheadline)
                                            .fontWeight(.bold)

                                        Spacer()

                                        // ✅ Buy Now
                                        Button {
                                            let cartItem = CartItem(
                                                foodId: item.id,
                                                foodDescription: item.description,
                                                foodImage: item.imageURL,
                                                restaurantId: item.restaurantId,
                                                foodPrice: item.price,
                                                quantity: 1
                                            )
                                            onBuyNow(cartItem)
                                        } label: {
                                            Image("ic_buy")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }

                                        // ✅ Add to Cart
                                        Button {
                                            addToCart(food: item)
                                        } label: {
                                            Image("ic_add_to_cart")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(hex: "F5F5F5").edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToDetail) {
                if let selected = selectedFoodItem, let restaurant = selectedRestaurant {
                    FoodDetailView(foodItem: selected, restaurant: restaurant)
                }
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

    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference(withPath: "cart/\(uid)").childByAutoId()

        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageURL,
            "foodPrice": food.price,
            "quantity": 1,
            "restaurantId": food.restaurantId,
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
                FoodItem(
                    id: "Burger",
                    description: "Delicious beef burger",
                    imageURL: "https://example.com/burger.jpg",
                    restaurantId: "res123",
                    price: 7.99
                ),
                FoodItem(
                    id: "Sushi",
                    description: "Fresh salmon sushi",
                    imageURL: "https://example.com/sushi.jpg",
                    restaurantId: "res123",
                    price: 12.99
                )
            ],
            keyword: "Burger",
            onBuyNow: { _ in }
        )
    }
}
