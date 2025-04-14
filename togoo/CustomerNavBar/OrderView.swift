//
//  OrderView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

// MARK: - Sheet Wrappers
struct DriverSheet: Identifiable {
    let id = UUID()
    let driverId: String
    let eta: String
}

struct RatingSheet: Identifiable {
    let id = UUID()
    let order: Order
}

struct DisputeSheet: Identifiable {
    let id = UUID()
    let order: Order
}

struct OrderView: View {
    @ObservedObject var viewModel = OrderViewModel()

    @State private var destinationView: AnyView?
    @State private var navigateToDestination = false

    @State private var driverSheet: DriverSheet?
    @State private var ratingSheet: RatingSheet?
    @State private var disputeSheet: DisputeSheet?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar
                Text("My Orders")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "F18D34"))

                // Order List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.orders) { order in
                            OrderCardView(
                                order: order,
                                onKnowDriver: {
                                    if let driverId = order.driverId, let eta = order.estimatedDeliveryTime {
                                        driverSheet = DriverSheet(driverId: driverId, eta: eta)
                                    }
                                },
                                onRateOrder: {
                                    ratingSheet = RatingSheet(order: order)
                                },
                                onLogComplaint: {
                                    disputeSheet = DisputeSheet(order: order)
                                }
                            )
                        }
                    }
                    .padding()
                }

                // Bottom Navigation
                bottomNavigationBar

                // Navigation Trigger
                NavigationLink(destination: destinationView, isActive: $navigateToDestination) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(item: $driverSheet) { sheet in
                DriverInfoView(driverId: sheet.driverId, eta: sheet.eta)
            }
            .sheet(item: $ratingSheet) { sheet in
                RatingDialogView(orderId: sheet.order.id,
                                 restaurantId: sheet.order.restaurantId ?? "",
                                 driverId: sheet.order.driverId ?? "") { role, uid, customerId, rating, comment in
                    viewModel.updateRating(role: role, uid: uid, customerId: customerId, rating: rating, comment: comment)
                }
            }
            .sheet(item: $disputeSheet) { sheet in
                DisputeFormView(orderId: sheet.order.id) { title, desc, reason, img in
                    if let img = img {
                        viewModel.uploadEvidence(orderId: sheet.order.id, title: title, description: desc, reason: reason, image: img) { url in
                            viewModel.submitDispute(orderId: sheet.order.id, title: title, description: desc, reason: reason, imageURL: url)
                        }
                    } else {
                        viewModel.submitDispute(orderId: sheet.order.id, title: title, description: desc, reason: reason, imageURL: nil)
                    }
                }
            }
        }
    }

    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            navItem(title: "Home", imageName: "ic_home", tab: "home") {
                destinationView = AnyView(CustomerHomeView())
                navigateToDestination = true
            }
            navItem(title: "Restaurants", imageName: "ic_restaurant", tab: "restaurants") {
                destinationView = AnyView(RestaurantView())
                navigateToDestination = true
            }
            navItem(title: "Orders", imageName: "ic_order", tab: "orders", isSelected: true) {
                // Already on Orders
            }
            navItem(title: "Account", imageName: "ic_account", tab: "account") {
                destinationView = AnyView(AccountView())
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
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
