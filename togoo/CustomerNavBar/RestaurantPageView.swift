//
//  RestaurantPageView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

struct RestaurantPageView: View {
    let restaurantId: String
    @State private var restaurant: Restaurant?
    @State private var featuredItems: [FoodItem] = []
    @State private var menuSections: [String: [FoodItem]] = [:]
    @State private var moreToExplore: [Restaurant] = []
    @State private var reviews: [(name: String, rating: Float, comment: String)] = []
    @State private var navigateToDestination = false
    @State private var destinationView: AnyView? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Full-width image
                if let imageURL = restaurant?.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 200)
                    .clipped()
                }

                HStack {
                    Button(action: {
                        navigateToDestination = true
                        destinationView = AnyView(RestaurantView())
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.primaryVariant)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .offset(y: -180)

                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant?.name ?? "")
                        .font(.title2.bold())
                        .foregroundColor(.black)

                    Text("\u{2B50} " + String(format: "%.1f", restaurant?.rating ?? 4.5))
                        .foregroundColor(.primaryVariant)

                    Text(restaurant?.address ?? "")
                        .foregroundColor(.darkGray)

                    Text(String(format: "%.1f km", restaurant?.distanceKm ?? 0))
                        .foregroundColor(.darkGray)

                    Text("\(restaurant?.etaMinutes ?? 0) mins away")
                        .foregroundColor(.gray)

                    if let hours = restaurant?.operatingHours {
                        let status = getOperatingHoursStatus(from: hours)
                        Text(status)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                Text("Reviews")
                    .font(.title3.bold())
                    .padding(.horizontal)

                ForEach(reviews.prefix(5), id: \.name) { review in
                    VStack(alignment: .leading) {
                        Text("\u{2B50} \(review.rating) — \(review.name): \(review.comment)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }

                Text("Featured Items")
                    .font(.title3.bold())
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(featuredItems) { item in
                            FoodItemCard(
                                foodName: item.id,
                                foodDescription: item.description,
                                foodPrice: item.price,
                                foodImageURL: item.imageURL,
                                onAddToCart: {
                                    addToCart(item: item)
                                },
                                onBuyNow: {
                                    if let r = restaurant {
                                           RestaurantHelper.setCurrentRestaurant(r)
                                       }
                                    destinationView = AnyView(CheckoutView(checkoutItems: [CartItem(
                                        foodId: item.id,
                                        foodDescription: item.description,
                                        foodImage: item.imageURL,
                                        restaurantId: item.restaurantId,
                                        foodPrice: item.price,
                                        quantity: 1
                                    )]))
                                    navigateToDestination = true
                                }
                            )
                            .onTapGesture {
                                if let r = restaurant {
                                    navigateTo(AnyView(FoodDetailView(foodItem: item, restaurant: r)))
                                } else {
                                    print("❌ Restaurant data not available for Featured Item tap.")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Text("Menu")
                    .font(.title3.bold())
                    .padding(.horizontal)

                ForEach(menuSections.keys.sorted(), id: \.self) { section in
                    VStack(alignment: .leading) {
                        Text(section)
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(menuSections[section] ?? []) { item in
                                    FoodItemCard(
                                        foodName: item.id,
                                        foodDescription: item.description,
                                        foodPrice: item.price,
                                        foodImageURL: item.imageURL,
                                        onAddToCart: {
                                            addToCart(item: item)
                                        },
                                        onBuyNow: {
                                            if let r = restaurant {
                                                   RestaurantHelper.setCurrentRestaurant(r)
                                               }
                                            destinationView = AnyView(CheckoutView(checkoutItems: [CartItem(
                                                foodId: item.id,
                                                foodDescription: item.description,
                                                foodImage: item.imageURL,
                                                restaurantId: item.restaurantId,
                                                foodPrice: item.price,
                                                quantity: 1
                                            )]))
                                            navigateToDestination = true
                                        }
                                    )
                                    .onTapGesture {
                                        if let r = restaurant {
                                            navigateTo(AnyView(FoodDetailView(foodItem: item, restaurant: r)))
                                        } else {
                                            print("❌ Restaurant data not available")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Text("More to Explore")
                    .font(.title3.bold())
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(moreToExplore) { r in
                            RestaurantCardView(restaurant: r, fullWidthImage: false) {
                                navigateTo(AnyView(RestaurantPageView(restaurantId: r.id)))                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(hex: "F5F5F5"))
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToDestination) {
            destinationView
        }
        .onAppear {
            loadRestaurantDetails()
        }
    }

    func addToCart(item: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let cartRef = Database.database().reference().child("cart").child(uid).childByAutoId()

        let cartData: [String: Any] = [
            "foodId": item.id,
            "foodDescription": item.description,
            "foodImage": item.imageURL,
            "foodPrice": item.price,
            "quantity": 1,
            "restaurantId": item.restaurantId
        ]

        cartRef.setValue(cartData) { error, _ in
            if error == nil {
                print("✅ Added \(item.id) to cart")
            }
        }
    }

    func getOperatingHoursStatus(from hours: [String: OperatingHours]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone(identifier: "America/Montreal")
        let today = dateFormatter.string(from: Date())

        guard let todayHours = hours[today] else {
            return "Hours unavailable"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone(identifier: "America/Montreal")

        let now = Date()
        let currentTimeStr = timeFormatter.string(from: now)

        guard
            let nowTime = timeFormatter.date(from: currentTimeStr),
            let openTime = timeFormatter.date(from: todayHours.open),
            let closeTime = timeFormatter.date(from: todayHours.close)
        else {
            return "Hours unavailable"
        }

        let nowMillis = nowTime.timeIntervalSince1970
        let openMillis = openTime.timeIntervalSince1970
        let closeMillis = closeTime.timeIntervalSince1970

        if nowMillis < openMillis {
            return "Opens at \(todayHours.open)"
        } else if nowMillis > closeMillis {
            return "Closed"
        } else {
            return "Closes at \(todayHours.close)"
        }
    }

    func parseTime(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: string)
    }

    func loadRestaurantDetails() {
        let ref = Database.database().reference().child("restaurant").child(restaurantId)

        ref.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            if let r = Restaurant(dict: dict, id: restaurantId) {
                self.restaurant = r
                loadReviews(for: r.id)
                loadFeaturedItems(for: r.id)
                loadMenu(for: r.id)
                loadMoreToExplore(excluding: r.id)
            }
        }
    }

    func loadFeaturedItems(for restaurantId: String) {
        Database.database().reference()
            .child("restaurant/\(restaurantId)/Special Offers")
            .observeSingleEvent(of: .value) { snapshot in
                var items: [FoodItem] = []
                for child in snapshot.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                    if let value = child.value as? [String: Any],
                       let description = value["description"] as? String,
                       let imageURL = value["imageURL"] as? String,
                       let price = value["price"] as? Double {
                        let item = FoodItem(id: child.key, description: description, imageURL: imageURL, restaurantId: restaurantId, price: price)
                        items.append(item)
                    }
                }
                self.featuredItems = items
            }
    }

    func loadMenu(for restaurantId: String) {
        Database.database().reference()
            .child("restaurant/\(restaurantId)/menu")
            .observeSingleEvent(of: .value) { snapshot in
                var sections: [String: [FoodItem]] = [:]
                for section in snapshot.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                    let sectionName = section.key
                    var items: [FoodItem] = []
                    for itemSnap in section.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                        if let value = itemSnap.value as? [String: Any],
                           let description = value["description"] as? String,
                           let imageURL = value["imageURL"] as? String,
                           let price = value["price"] as? Double {
                            let item = FoodItem(id: itemSnap.key, description: description, imageURL: imageURL, restaurantId: restaurantId, price: price)
                            items.append(item)
                        }
                    }
                    sections[sectionName] = items
                }
                self.menuSections = sections
            }
    }

    func loadReviews(for restaurantId: String) {
        let ratingsRef = Database.database().reference().child("restaurant/\(restaurantId)/ratings")
        ratingsRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { snapshot in
            var comments: [(String, Float, String)] = []
            for child in snapshot.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                let comment = child.childSnapshot(forPath: "comment").value as? String ?? ""
                let rating = child.childSnapshot(forPath: "value").value as? Float ?? 0.0
                let uid = child.key

                Database.database().reference().child("customer/\(uid)/name").observeSingleEvent(of: .value) { userSnap in
                    let name = userSnap.value as? String ?? "User"
                    comments.append((name, rating, comment))
                    self.reviews = comments.sorted { $0.1 > $1.1 }
                }
            }
        }
    }

    func loadMoreToExplore(excluding currentId: String) {
        Database.database().reference().child("restaurant").observeSingleEvent(of: .value) { snapshot in
            var list: [Restaurant] = []
            for snap in snapshot.children.allObjects.compactMap({ $0 as? DataSnapshot }) {
                guard let dict = snap.value as? [String: Any], snap.key != currentId,
                      let restaurant = Restaurant(dict: dict, id: snap.key) else { continue }
                list.append(restaurant)
            }
            self.moreToExplore = list.sorted { $0.distanceKm < $1.distanceKm }.prefix(7).map { $0 }
        }
    }
    
    func navigateTo(_ view: AnyView) {
        destinationView = view
        navigateToDestination = true
    }
}

#Preview {
    RestaurantPageView(restaurantId: "sampleRestaurantId")
}


