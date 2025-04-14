//
//  RestaurantHomeView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct RestaurantHomeView: View {
    @StateObject private var viewModel = RestaurantHomeViewModel()
    @State private var navigateTo: AnyView? = nil
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Orders")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryVariant)

                // View Ongoing Orders
                Button(action: {
                    navigateTo = AnyView(RestaurantOngoingOrdersView())
                    navigate = true
                }) {
                    Text("View Ongoing Orders")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                        .padding(.vertical, 12)
                }

                // Order List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.placedOrders.isEmpty {
                            Text("No available orders.")
                                .foregroundColor(.gray)
                                .padding(.top, 32)
                        }

                        ForEach(viewModel.placedOrders, id: \ .orderId) { order in
                            RestaurantOrderCard(order: order,
                                onAccept: {
                                    viewModel.updateOrderStatus(orderId: order.orderId, newStatus: "accepted")
                                    viewModel.notifyDrivers(order: order)
                                    viewModel.placedOrders.removeAll { $0.orderId == order.orderId }
                                },
                                onDecline: {
                                    viewModel.updateOrderStatus(orderId: order.orderId, newStatus: "declined")
                                    viewModel.placedOrders.removeAll { $0.orderId == order.orderId }
                                }
                            )
                        }
                    }
                    .padding()
                }

                // Bottom Navigation
                RestaurantBottomNavigationView(selectedTab: "orders") {
                    navigateTo = $0
                    navigate = true
                }

                NavigationLink(destination: navigateTo, isActive: $navigate) {
                    EmptyView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct RestaurantHomeView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantHomeView()
    }
}
