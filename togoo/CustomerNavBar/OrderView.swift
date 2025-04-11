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
                HStack {
                    Button {
                        destinationView = AnyView(CustomerHomeView())
                        navigateToDestination = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.accentColor)
                    }
                    Spacer()
                    Text("My Orders")
                        .font(.headline)
                    Spacer()
                    Spacer().frame(width: 60)
                }
                .padding()

                // Order List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.orders) { order in
                            OrderCardView(
                                order: order,
                                onKnowDriver: {
                                    if let driverId = order.driverId, let eta = order.estimatedDeliveryTime {
                                        DispatchQueue.main.async {
                                            driverSheet = DriverSheet(driverId: driverId, eta: eta)
                                        }
                                    }
                                },
                                onRateOrder: {
                                    DispatchQueue.main.async {
                                        ratingSheet = RatingSheet(order: order)
                                    }
                                },
                                onLogComplaint: {
                                    DispatchQueue.main.async {
                                        disputeSheet = DisputeSheet(order: order)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }

                // Bottom Nav
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
            CustomerBottomNavItem(imageName: "ic_home", title: "Home", isSelected: false) {
                destinationView = AnyView(CustomerHomeView())
                navigateToDestination = true
            }
            .frame(maxWidth: .infinity)

            CustomerBottomNavItem(imageName: "ic_restaurant", title: "Restaurants", isSelected: true) {}
                .frame(maxWidth: .infinity)

            CustomerBottomNavItem(imageName: "ic_browse", title: "Browse", isSelected: false) {
                destinationView = AnyView(BrowseView())
                navigateToDestination = true
            }
            .frame(maxWidth: .infinity)

            CustomerBottomNavItem(imageName: "ic_order", title: "Order", isSelected: false) {
                destinationView = AnyView(OrderView())
                navigateToDestination = true
            }
            .frame(maxWidth: .infinity)

            CustomerBottomNavItem(imageName: "ic_account", title: "Account", isSelected: false) {
                destinationView = AnyView(AccountView())
                navigateToDestination = true
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white)
    }
}
