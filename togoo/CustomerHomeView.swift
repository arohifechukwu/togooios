
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
    @State private var notificationCount: Int = 0

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
            listenForNotificationUpdates()
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
            ZStack(alignment: .topTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image("ic_notification")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                if notificationCount > 0 {
                    Text("\(notificationCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
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
        VStack(alignment: .leading, spacing: 8) {
            if !searchSuggestions.isEmpty {
                searchSuggestionList

                if showViewAllLink {
                    viewAllResultsButton
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var searchSuggestionList: some View {
        List(searchSuggestions) { food in
            Button {
                fetchRestaurant(for: food.restaurantId) { restaurant in
                    if let restaurant = restaurant {
                        destinationView = AnyView(FoodDetailView(foodItem: food, restaurant: restaurant))
                        navigateToDestination = true
                    }
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
        .frame(height: CGFloat(searchSuggestions.count * 70))
    }
    
    
    private var viewAllResultsButton: some View {
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
                                } else if category.hasImageUrl,
                                          let urlString = category.imageUrl,
                                          let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Color.gray
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }

                                Text(category.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
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
    
    
    
    // MARK: - Helper: Map imageResId to SwiftUI asset name
    private func localImageName(for resId: Int?) -> String? {
        guard let resId = resId else { return nil }
        
        switch resId {
            case 1: return "pizza"
            case 2: return "burger"
            case 3: return "sushi"
            case 4: return "spaghetti"
            case 5: return "shrimp"
            case 6: return "salad"
            case 7: return "tacos"
            case 8: return "cupcake"
            default: return nil
        }
    }

    private var specialOffersView: some View {
        VStack(alignment: .leading) {
            Text("Special Offers").font(.headline).padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(specialOffers) { offer in
                        Button {
                            fetchRestaurant(for: offer.restaurantId) { restaurant in
                                if let restaurant = restaurant {
                                    destinationView = AnyView(FoodDetailView(foodItem: offer, restaurant: restaurant))
                                    navigateToDestination = true
                                }
                            }
                        } label: {
                            FoodItemCard(
                                foodName: offer.id,
                                foodDescription: offer.description,
                                foodPrice: offer.price,
                                foodImageURL: offer.imageURL,
                                onAddToCart: { addToCart(food: offer) },
                                onBuyNow: { navigateToCheckout(with: offer) }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var topPicksView: some View {
        VStack(alignment: .leading) {
            Text("Top Picks").font(.headline).padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(topPicks) { pick in
                        Button {
                            fetchRestaurant(for: pick.restaurantId) { restaurant in
                                if let restaurant = restaurant {
                                    destinationView = AnyView(FoodDetailView(foodItem: pick, restaurant: restaurant))
                                    navigateToDestination = true
                                }
                            }
                        } label: {
                            FoodItemCard(
                                foodName: pick.id,
                                foodDescription: pick.description,
                                foodPrice: pick.price,
                                foodImageURL: pick.imageURL,
                                onAddToCart: { addToCart(food: pick) },
                                onBuyNow: { navigateToCheckout(with: pick) }
                            )
                        }
                    }
                }
                .padding(.horizontal)
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
        dbRef.child("customer").child(uid).child("location").setValue([
            "latitude": latitude,
            "longitude": longitude
        ])
    }
    
    private func fetchRestaurant(for restaurantId: String, completion: @escaping (Restaurant?) -> Void) {
        dbRef.child("restaurant").child(restaurantId).observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any],
               let restaurant = Restaurant(dict: data, id: restaurantId) {
                completion(restaurant)
            } else {
                completion(nil)
            }
        }
    }

    private func addToCart(food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = dbRef.child("cart").child(uid).childByAutoId()
        let cartItem: [String: Any] = [
            "foodId": food.id,
            "foodDescription": food.description,
            "foodImage": food.imageURL,
            "foodPrice": food.price,
            "quantity": 1,
            "cartItemId": ref.key ?? ""
        ]
        ref.setValue(cartItem)
    }

    private func navigateToCheckout(with food: FoodItem) {
        let checkoutItem = CartItem(
            foodId: food.id,
            foodDescription: food.description,
            foodImage: food.imageURL,
            restaurantId: food.restaurantId,
            foodPrice: food.price,
            quantity: 1
        )
        destinationView = AnyView(CheckoutView(checkoutItems: [checkoutItem]))
        navigateToDestination = true
    }

    private func searchMenuItems(query: String) {
        let queryLower = query.lowercased()
        
        dbRef.child("restaurant").observeSingleEvent(of: .value, with: { snapshot in
            var prefixMatches: [FoodItem] = []
            var substringMatches: [FoodItem] = []

            for child in snapshot.children.allObjects {
                guard let restaurantSnap = child as? DataSnapshot else { continue }

                let menuSnap = restaurantSnap.childSnapshot(forPath: "menu")
                for menuChild in menuSnap.children.allObjects {
                    guard let categorySnap = menuChild as? DataSnapshot else { continue }

                    for foodChild in categorySnap.children.allObjects {
                        guard let foodSnap = foodChild as? DataSnapshot else { continue }

                        let id = foodSnap.key.lowercased()
                        let description = foodSnap.childSnapshot(forPath: "description").value as? String ?? ""
                        let imageURL = foodSnap.childSnapshot(forPath: "imageURL").value as? String ?? ""
                        let price = foodSnap.childSnapshot(forPath: "price").value as? Double ?? 0.0
                        let restaurantId = restaurantSnap.key // capture restaurant ID if needed

                        let foodItem = FoodItem(id: foodSnap.key, description: description, imageURL: imageURL, restaurantId: restaurantId, price: price)

                        if id.hasPrefix(queryLower) {
                            prefixMatches.append(foodItem)
                        } else if id.contains(queryLower) {
                            substringMatches.append(foodItem)
                        }
                    }
                }
            }

            let mergedResults = prefixMatches + substringMatches

            DispatchQueue.main.async {
                self.searchSuggestions = Array(mergedResults.prefix(5))
                self.allSearchResults = mergedResults
                self.showViewAllLink = mergedResults.count > 5
            }
        }, withCancel: { error in
            print("❌ Failed to fetch search results: \(error.localizedDescription)")
        })
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
        dbRef.child("restaurant").observeSingleEvent(of: .value, with: { snapshot in
            var offers: [FoodItem] = []

            for child in snapshot.children {
                guard let restaurantSnap = child as? DataSnapshot else { continue }
                let restaurantId = restaurantSnap.key

                let offersSnap = restaurantSnap.childSnapshot(forPath: "Special Offers")
                for offerChild in offersSnap.children {
                    guard let itemSnap = offerChild as? DataSnapshot else { continue }

                    let id = itemSnap.key
                    let description = itemSnap.childSnapshot(forPath: "description").value as? String
                    let imageUrl = itemSnap.childSnapshot(forPath: "imageURL").value as? String
                    let price = itemSnap.childSnapshot(forPath: "price").value as? Double

                    if let description = description, let imageUrl = imageUrl, let price = price {
                        offers.append(FoodItem(id: id, description: description, imageURL: imageUrl, restaurantId: restaurantId, price: price))
                    }
                }
            }

            DispatchQueue.main.async {
                specialOffers = offers
            }

        }, withCancel: { error in
            print("❌ Failed to fetch special offers: \(error.localizedDescription)")
        })
    }

    private func fetchTopPicks() {
        dbRef.child("restaurant").observeSingleEvent(of: .value, with: { snapshot in
            var picks: [FoodItem] = []

            for case let restaurantSnap as DataSnapshot in snapshot.children {
                let restaurantId = restaurantSnap.key
                let picksSnap = restaurantSnap.childSnapshot(forPath: "Top Picks")

                for case let itemSnap as DataSnapshot in picksSnap.children {
                    let id = itemSnap.key
                    let description = itemSnap.childSnapshot(forPath: "description").value as? String
                    let imageUrl = itemSnap.childSnapshot(forPath: "imageURL").value as? String
                    let price = itemSnap.childSnapshot(forPath: "price").value as? Double

                    if let description = description, let imageUrl = imageUrl, let price = price {
                        picks.append(FoodItem(id: id, description: description, imageURL: imageUrl, restaurantId: restaurantId, price: price))
                    }
                }
            }

            DispatchQueue.main.async {
                topPicks = picks
            }

        }, withCancel: { error in
            print("❌ Failed to fetch top picks: \(error.localizedDescription)")
        })
    }

    private func listenForNotificationUpdates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        dbRef.child("orders")
            .queryOrdered(byChild: "customer/id")
            .queryEqual(toValue: uid)
            .observe(.value) { snapshot in
                var count = 0
                for child in snapshot.children {
                    if let orderSnap = child as? DataSnapshot,
                       orderSnap.hasChild("updateLogs") {
                        count += Int(orderSnap.childSnapshot(forPath: "updateLogs").childrenCount)
                    }
                }
                notificationCount = count
            }
    }
}

struct CustomerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeView()
    }
}
