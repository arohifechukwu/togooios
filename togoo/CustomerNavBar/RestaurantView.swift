//
//  RestaurantView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

struct RestaurantView: View {
    @State private var restaurantList: [Restaurant] = []
    @State private var searchQuery: String = ""
    @State private var searchResults: [FoodItem] = []
    @State private var showViewAllLink: Bool = false
    @State private var featuredCategories: [FoodCategory] = []
    @State private var navigateToDestination = false
    @State private var destinationView: AnyView? = nil
    @State private var selectedFoodItem: FoodItem?
    @State private var selectedRestaurant: Restaurant?
    @State private var selectedTab: String = "restaurants"

    @StateObject private var locationManager = AppLocationManager()
    private var dbRef: DatabaseReference { Database.database().reference() }

    let primaryColor = Color(hex: "F18D34")
    let white = Color.white
    let lightGray = Color(hex: "F5F5F5")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        searchBar
                        if !searchResults.isEmpty {
                            searchSuggestionList
                        }
                        if showViewAllLink {
                            viewAllResultsButton
                        }
                        featuredCategoriesGrid
                        Text("Restaurants Near You")
                            .font(.title3.bold())
                            .padding(.horizontal)
                        restaurantGrid
                    }
                    .padding(.bottom, 56)
                }
                .background(lightGray)
                .onAppear {
                    fetchFeaturedCategories()
                    fetchUserLocationAndLoadRestaurants()
                }

                bottomNavigationBar
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToDestination) {
                if let food = selectedFoodItem, let restaurant = selectedRestaurant {
                    FoodDetailView(foodItem: food, restaurant: restaurant)
                } else if let view = destinationView {
                    view
                } else {
                    EmptyView()
                }
            }
        }
    }

    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            navItem(title: "Home", imageName: "ic_home", tab: "home") {
                destinationView = AnyView(CustomerHomeView())
                selectedTab = "home"
                navigateToDestination = true
            }
            navItem(title: "Restaurants", imageName: "ic_restaurant", tab: "restaurants", isSelected: true) {
                // already here
            }
            navItem(title: "Orders", imageName: "ic_order", tab: "orders") {
                destinationView = AnyView(OrderView())
                selectedTab = "orders"
                navigateToDestination = true
            }
            navItem(title: "Account", imageName: "ic_account", tab: "account") {
                destinationView = AnyView(AccountView())
                selectedTab = "account"
                navigateToDestination = true
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -1)
    }

    private func navItem(title: String, imageName: String, tab: String, isSelected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color(hex: "F18D34") : Color(hex: "757575"))

                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Color(hex: "F18D34") : Color(hex: "757575"))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        HStack {
            Text("Restaurants")
                .font(.title2.bold())
            Spacer()
            NavigationLink(destination: CartView()) {
                Image("ic_cart")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var searchBar: some View {
        TextField("Search menu...", text: $searchQuery)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding(.horizontal)
            .onChange(of: searchQuery) { query in
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    searchResults = []
                    showViewAllLink = false
                } else {
                    searchMenuItems(query: query)
                }
            }
    }

    private var searchSuggestionList: some View {
        List(searchResults.prefix(5)) { food in
            Button {
                fetchRestaurant(for: food.restaurantId) { restaurant in
                    self.selectedFoodItem = food
                    self.selectedRestaurant = restaurant
                    navigateToDestination = true
                }
            } label: {
                HStack {
                    AsyncImage(url: URL(string: food.imageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)

                    VStack(alignment: .leading) {
                        Text(food.id).font(.headline)
                        Text(food.description).font(.subheadline)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .frame(height: CGFloat(min(searchResults.count, 5) * 70))
    }

    private var viewAllResultsButton: some View {
        Button(action: {
            destinationView = AnyView(ViewAllView(results: searchResults, keyword: searchQuery) { cartItem in
                destinationView = AnyView(CheckoutView(checkoutItems: [cartItem]))
                navigateToDestination = true
            })
            navigateToDestination = true
        }) {
            Text("View all \(searchResults.count) results")
                .foregroundColor(primaryColor)
                .padding(.horizontal)
                .padding(.top, -8)
                .font(.subheadline.bold())
        }
    }

    private var featuredCategoriesGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(featuredCategories) { category in
                NavigationLink(destination: FeaturedCategoryView(selectedCategory: category.name)) {
                    VStack {
                        Image(category.imageName ?? "")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
        }
        .padding(.horizontal)
    }

    private var restaurantGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(restaurantList) { restaurant in
                RestaurantCardView(restaurant: restaurant, fullWidthImage: false) {
                    destinationView = AnyView(RestaurantPageView(restaurantId: restaurant.id))
                    navigateToDestination = true
                }
            }
        }
        .padding(.horizontal)
    }

    private func fetchRestaurant(for restaurantId: String, completion: @escaping (Restaurant?) -> Void) {
        dbRef.child("restaurant").child(restaurantId).getData { error, snapshot in
            if let data = snapshot?.value as? [String: Any],
               let restaurant = Restaurant(dict: data, id: restaurantId) {
                completion(restaurant)
            } else {
                print("❌ Failed to fetch restaurant for ID: \(restaurantId)")
                completion(nil)
            }
        }
    }

    private func fetchFeaturedCategories() {
        featuredCategories = [
            FoodCategory(name: "Pizza", imageName: "pizza"),
            FoodCategory(name: "Burgers", imageName: "burger"),
            FoodCategory(name: "Sushi", imageName: "sushi"),
            FoodCategory(name: "Pasta", imageName: "spaghetti"),
            FoodCategory(name: "Seafood", imageName: "shrimp"),
            FoodCategory(name: "Salads", imageName: "salad"),
            FoodCategory(name: "Tacos", imageName: "tacos"),
            FoodCategory(name: "Desserts", imageName: "cupcake")
        ]
    }

    private func fetchUserLocationAndLoadRestaurants() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        let roles = ["customer", "driver", "restaurant"]
        let rootRef = Database.database().reference()

        rootRef.observeSingleEvent(of: .value) { snapshot in
            for role in roles {
                if snapshot.childSnapshot(forPath: role).hasChild(currentUID) {
                    let userSnap = snapshot.childSnapshot(forPath: "\(role)/\(currentUID)/location")
                    let latVal = userSnap.childSnapshot(forPath: "latitude").value
                    let lonVal = userSnap.childSnapshot(forPath: "longitude").value

                    let lat = Double(String(describing: latVal ?? "0")) ?? 0.0
                    let lon = Double(String(describing: lonVal ?? "0")) ?? 0.0

                    loadRestaurants(userLat: lat, userLon: lon)
                    return
                }
            }
            // Fallback if user location is not found
            loadRestaurants(userLat: 0.0, userLon: 0.0)
        }
    }

    private func loadRestaurants(userLat: Double, userLon: Double) {
        dbRef.child("restaurant").observeSingleEvent(of: .value, with: { snapshot in
            var tempList: [Restaurant] = []

            for case let child as DataSnapshot in snapshot.children {
                guard
                    let name = child.childSnapshot(forPath: "name").value as? String,
                    let imageUrl = child.childSnapshot(forPath: "imageURL").value as? String,
                    let latVal = child.childSnapshot(forPath: "location/latitude").value,
                    let lonVal = child.childSnapshot(forPath: "location/longitude").value
                else { continue }

                let latStr = String(describing: latVal)
                let lonStr = String(describing: lonVal)
                let lat = Double(latStr) ?? 0.0
                let lon = Double(lonStr) ?? 0.0

                let distance = AppLocationManager.calculateDistance(lat1: userLat, lon1: userLon, lat2: lat, lon2: lon)
                let eta = Int((distance / 40.0) * 60.0)

                let address = child.childSnapshot(forPath: "address").value as? String ?? "Address unavailable"

                var opHours: [String: OperatingHours] = [:]
                if let rawHours = child.childSnapshot(forPath: "operatingHours").value as? [String: Any] {
                    for (day, value) in rawHours {
                        if let hourDict = value as? [String: Any],
                           let parsed = OperatingHours(dict: hourDict) {
                            opHours[day] = parsed
                        }
                    }
                }

                let restaurant = Restaurant(
                    id: child.key,
                    name: name,
                    address: address,
                    imageURL: imageUrl,
                    location: LocationCoordinates(latitude: lat, longitude: lon),
                    operatingHours: opHours,
                    rating: 4.5,
                    distanceKm: distance,
                    etaMinutes: eta
                )
                tempList.append(restaurant)
            }
            self.restaurantList = tempList
        }, withCancel: { error in
            print("❌ Failed to load restaurants: \(error.localizedDescription)")
        })
    }

    private func searchMenuItems(query: String) {
        let queryLower = query.lowercased()
        dbRef.child("restaurant").observeSingleEvent(of: .value) { snapshot in
            var results: [FoodItem] = []
            for child in snapshot.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                let restaurantId = child.key
                let menuSnap = child.childSnapshot(forPath: "menu")
                for category in menuSnap.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                    for foodSnap in category.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                        let id = foodSnap.key.lowercased()
                        let desc = foodSnap.childSnapshot(forPath: "description").value as? String ?? ""
                        let image = foodSnap.childSnapshot(forPath: "imageURL").value as? String ?? ""
                        let price = foodSnap.childSnapshot(forPath: "price").value as? Double ?? 0.0

                        let item = FoodItem(id: id, description: desc, imageURL: image, restaurantId: restaurantId, price: price)

                        if id.hasPrefix(queryLower) {
                            results.insert(item, at: 0)
                        } else if id.contains(queryLower) {
                            results.append(item)
                        }
                    }
                }
            }
            searchResults = results
            showViewAllLink = results.count > 5
        }
    }
}

struct RestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantView()
    }
}
