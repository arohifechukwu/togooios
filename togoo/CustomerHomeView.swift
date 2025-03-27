//
//  CustomerHomeView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//


  
import SwiftUI
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

struct CustomerHomeView: View {
    @State private var locationText: String = "Fetching location..."
    @State private var searchQuery: String = ""
    @State private var searchSuggestions: [FoodItem] = []
    @State private var featuredCategories: [FoodCategory] = []
    @State private var specialOffers: [FoodItem] = []
    @State private var topPicks: [FoodItem] = []
    @State private var allSearchResults: [FoodItem] = []
    @State private var showViewAllLink: Bool = false

    @State private var navigateToDestination: Bool = false
    @State private var destinationView: AnyView? = nil

    let primaryColor = Color(hex: "F18D34")
    let lightGray = Color(hex: "F5F5F5")
    let white = Color.white

    private var dbRef: DatabaseReference { Database.database().reference() }
    @StateObject private var locationManager = LocationManager()

    var body: some View {
            ScrollView {
                VStack(spacing: 14) {
                    headerView
                    searchBar
                    searchResultsView
                    featuredCategoryScrollView
                    specialOffersView
                    topPicksView
                }
                .padding(.bottom, 16)
            }
            .background(lightGray.edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .onAppear {
                locationText = locationManager.locationName
                fetchFeaturedCategories()
                fetchSpecialOffers()
                fetchTopPicks()
                locationManager.startUpdating()
            }
            .onChange(of: locationManager.location) { newLocation in
                handleLocationChange(newLocation)
            }
            .onReceive(locationManager.$locationName) { updatedName in
                locationText = updatedName
            }
            .navigationDestination(isPresented: $navigateToDestination) {
                destinationView
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    bottomNavigationBar
                }
            }
    }

    private var headerView: some View {
        HStack {
            Text(locationText)
                .font(.subheadline)
            Spacer()
            NavigationLink(destination: CartView()) {
                Image("ic_cart")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private var searchBar: some View {
        TextField("Search menu...", text: $searchQuery)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(.horizontal)
            .onChange(of: searchQuery) { newQuery in
                let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    searchMenuItems(query: trimmed)
                } else {
                    searchSuggestions = []
                }
            }
    }
    
    private var searchResultsView: some View {
        Group {
            if !searchSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    List(searchSuggestions) { food in
                        NavigationLink(destination: FoodDetailView(foodItem: food)) {
                            HStack {
                                AsyncImage(url: URL(string: food.imageUrl)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(6)

                                VStack(alignment: .leading) {
                                    Text(food.id)
                                        .font(.headline)
                                    Text(food.description)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: CGFloat(searchSuggestions.count * 70)) // Adjust based on your row height

                    // 🔗 View all results link
                    if showViewAllLink {
                        Button(action: {
                            destinationView = AnyView(
                                ViewAllView(results: allSearchResults, keyword: searchQuery) { cartItem in
                                    destinationView = AnyView(CheckoutView(checkoutItems: [cartItem]))
                                    navigateToDestination = true
                                }
                            )
                            navigateToDestination = true
                        }) {
                            Text("View all \(allSearchResults.count) results")
                                .foregroundColor(primaryColor)
                                .padding(.horizontal)
                                .padding(.top, -8)
                                .font(.subheadline.bold())
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var featuredCategoryScrollView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Featured Categories")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredCategories) { category in
                        NavigationLink(destination: FeaturedCategoryView(selectedCategory: category.name)) {
                            VStack(spacing: 6) {
                                if let imageName = category.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Color.gray
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                                Text(category.name)
                                    .font(.caption)
                                    .foregroundColor(.darkGray) // 
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var specialOffersView: some View {
        VStack(alignment: .leading) {
            Text("Special Offers")
                .font(.headline)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(specialOffers) { offer in
                        NavigationLink(destination: FoodDetailView(foodItem: offer)) {
                            FoodItemCard(
                                foodName: offer.id,
                                foodDescription: offer.description,
                                foodPrice: offer.price,
                                foodImageURL: offer.imageUrl,
                                onAddToCart: {
                                    addToCart(food: offer)
                                },
                                onBuyNow: {
                                    navigateToCheckout(with: offer)
                                }
                            )
                        }
                    }
                }.padding(.horizontal)
            }
        }
    }

    private var topPicksView: some View {
        VStack(alignment: .leading) {
            Text("Top Picks")
                .font(.headline)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(topPicks) { pick in
                        NavigationLink(destination: FoodDetailView(foodItem: pick)) {
                            FoodItemCard(
                                foodName: pick.id,
                                foodDescription: pick.description,
                                foodPrice: pick.price,
                                foodImageURL: pick.imageUrl,
                                onAddToCart: {
                                    addToCart(food: pick)
                                },
                                onBuyNow: {
                                    navigateToCheckout(with: pick)
                                }
                            )
                        }
                    }
                }.padding(.horizontal)
            }
        }
    }

    private var bottomNavigationBar: some View {
        HStack {
            CustomerBottomNavItem(imageName: "ic_home", title: "Home", isSelected: true) {}
            Spacer()
            CustomerBottomNavItem(imageName: "ic_restaurant", title: "Restaurants", isSelected: false) {
                destinationView = AnyView(RestaurantView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_browse", title: "Browse", isSelected: false) {
                destinationView = AnyView(BrowseView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_order", title: "Order", isSelected: false) {
                destinationView = AnyView(OrderView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_account", title: "Account", isSelected: false) {
                destinationView = AnyView(AccountView())
                navigateToDestination = true
            }
        }
        .padding(.vertical, 8)
        .background(white)
    }

    private func handleLocationChange(_ newLocation: CLLocation?) {
        if let loc = newLocation {
            updateUserLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        }
    }

    private func updateUserLocation(latitude: Double, longitude: Double) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        dbRef.child("customer").child(uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                dbRef.child("customer").child(uid).child("location").setValue([
                    "latitude": latitude,
                    "longitude": longitude
                ]) { error, _ in
                    if let error = error {
                        print("Failed to update customer location: \(error.localizedDescription)")
                    } else {
                        print("Customer location updated successfully")
                    }
                }
            }
        }
    }
    
    
    // Adds a food item to Firebase cart
    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Reference: cart/<uid>/autoId
        let ref = Database.database().reference(withPath: "cart").child(uid).childByAutoId()

        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageUrl,
            "foodPrice": food.price,
            "quantity": 1,
            "cartItemId": ref.key ?? "" // Optional, helpful for delete
        ]

        ref.setValue(cartItem) { error, _ in
            if let error = error {
                print("❌ Failed to add to cart: \(error.localizedDescription)")
            } else {
                print("✅ Added to cart under UID \(uid) with key \(ref.key ?? "N/A")")
            }
        }
    }

    // Navigates to CheckoutView with the selected item
    private func navigateToCheckout(with food: FoodItem) {
        let checkoutItem = CartItem(
            foodId: food.id,
            foodDescription: food.description,
            foodImage: food.imageUrl,
            foodPrice: food.price,
            quantity: 1
        )
        destinationView = AnyView(CheckoutView(checkoutItems: [checkoutItem]))
        navigateToDestination = true
    }
    

    private func searchMenuItems(query: String) {
        let queryLower = query.lowercased()
        dbRef.child("restaurant").observeSingleEvent(of: .value) { snapshot in
            var prefixMatches: [FoodItem] = []
            var substringMatches: [FoodItem] = []

            for case let restaurantSnap as DataSnapshot in snapshot.children {
                let menuSnap = restaurantSnap.childSnapshot(forPath: "menu")
                for categorySnap in menuSnap.children {
                    if let category = categorySnap as? DataSnapshot {
                        for foodSnap in category.children {
                            if let foodData = foodSnap as? DataSnapshot {
                                let id = foodData.key.lowercased()
                                let description = foodData.childSnapshot(forPath: "description").value as? String ?? ""
                                let imageUrl = foodData.childSnapshot(forPath: "imageURL").value as? String ?? ""
                                let price = foodData.childSnapshot(forPath: "price").value as? Double ?? 0.0

                                let foodItem = FoodItem(id: foodData.key, description: description, imageUrl: imageUrl, price: price)

                                if id.hasPrefix(queryLower) {
                                    prefixMatches.append(foodItem)
                                } else if id.contains(queryLower) {
                                    substringMatches.append(foodItem)
                                }
                            }
                        }
                    }
                }
            }

            let mergedResults = prefixMatches + substringMatches

            DispatchQueue.main.async {
                // Show top 5
                self.searchSuggestions = Array(mergedResults.prefix(5))

                // Store all results in a global var if needed for ViewAllView
                self.allSearchResults = mergedResults
                self.showViewAllLink = mergedResults.count > 5
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

    private func fetchSpecialOffers() {
        dbRef.child("restaurant").observeSingleEvent(of: .value) { snapshot in
            var offers: [FoodItem] = []
            for case let restaurantSnap as DataSnapshot in snapshot.children {
                let offersSnap = restaurantSnap.childSnapshot(forPath: "Special Offers")
                for case let itemSnap as DataSnapshot in offersSnap.children {
                    let id = itemSnap.key
                    let description = itemSnap.childSnapshot(forPath: "description").value as? String
                    let imageUrl = itemSnap.childSnapshot(forPath: "imageURL").value as? String
                    let price = itemSnap.childSnapshot(forPath: "price").value as? Double
                    if let description = description, let imageUrl = imageUrl, let price = price {
                        offers.append(FoodItem(id: id, description: description, imageUrl: imageUrl, price: price))
                    }
                }
            }
            DispatchQueue.main.async {
                specialOffers = offers
            }
        }
    }

    private func fetchTopPicks() {
        dbRef.child("restaurant").observeSingleEvent(of: .value) { snapshot in
            var picks: [FoodItem] = []
            for case let restaurantSnap as DataSnapshot in snapshot.children {
                let picksSnap = restaurantSnap.childSnapshot(forPath: "Top Picks")
                for case let itemSnap as DataSnapshot in picksSnap.children {
                    let id = itemSnap.key
                    let description = itemSnap.childSnapshot(forPath: "description").value as? String
                    let imageUrl = itemSnap.childSnapshot(forPath: "imageURL").value as? String
                    let price = itemSnap.childSnapshot(forPath: "price").value as? Double
                    if let description = description, let imageUrl = imageUrl, let price = price {
                        picks.append(FoodItem(id: id, description: description, imageUrl: imageUrl, price: price))
                    }
                }
            }
            DispatchQueue.main.async {
                topPicks = picks
            }
        }
    }
}

struct CustomerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeView()
    }
}
