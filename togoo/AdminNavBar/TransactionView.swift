//
//  TransactionView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//



import SwiftUI
import FirebaseDatabase

struct TransactionView: View {
    @State private var orders: [OrderCard] = []
    @State private var destinationView: AnyView? = nil
    @State private var navigateToHome = false
    @State private var selectedTab: Tab = .transaction

    let white = Color.white
    let lightGray = Color(hex: "F5F5F5")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("All Orders")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 44)
                .padding()
                .background(Color(hex: "F18D34"))

                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(orders) { order in
                            OrdersCardView(order: order)
                        }
                    }
                    .padding()
                }

                // Bottom Nav
                HStack {
                    Spacer()
                    AdminBottomNavItem(imageName: "ic_dashboard", title: Tab.dashboard.rawValue, isSelected: selectedTab == .dashboard) {
                        selectedTab = .dashboard
                        destinationView = AnyView(AdminHomeView())
                        navigateToHome = true
                    }
                    Spacer()
                    AdminBottomNavItem(imageName: "ic_users", title: Tab.users.rawValue, isSelected: selectedTab == .users) {
                        selectedTab = .users
                        destinationView = AnyView(UsersView())
                        navigateToHome = true
                    }
                    Spacer()
                    AdminBottomNavItem(imageName: "ic_approvals", title: Tab.approvals.rawValue, isSelected: selectedTab == .approvals) {
                        selectedTab = .approvals
                        destinationView = AnyView(ApprovalView())
                        navigateToHome = true
                    }
                    Spacer()
                    AdminBottomNavItem(imageName: "ic_transaction", title: Tab.transaction.rawValue, isSelected: selectedTab == .transaction) {
                        selectedTab = .transaction
                    }
                    Spacer()
                    AdminBottomNavItem(imageName: "ic_settings", title: Tab.settings.rawValue, isSelected: selectedTab == .settings) {
                        selectedTab = .settings
                        destinationView = AnyView(SettingsView())
                        navigateToHome = true
                    }
                    Spacer()
                }
                .padding()
                .background(white)
                .shadow(radius: 4)
            }
            .background(lightGray)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                destinationView
            }
            .onAppear {
                fetchOrders()
            }
        }
    }

    private func fetchOrders() {
        let ref = Database.database().reference().child("orders")
        ref.observeSingleEvent(of: .value) { snapshot in
            var loadedOrders: [OrderCard] = []

            for child in snapshot.children {
                guard let orderSnap = child as? DataSnapshot else { continue }

                let orderId = orderSnap.key
                let itemsSnap = orderSnap.childSnapshot(forPath: "orderDetails/items")
                var items: [AdminOrderItem] = []

                for item in itemsSnap.children {
                    guard let itemSnap = item as? DataSnapshot else { continue }

                    let foodDesc = itemSnap.childSnapshot(forPath: "foodDescription").value as? String ?? ""
                    let foodImage = itemSnap.childSnapshot(forPath: "foodImage").value as? String ?? ""
                    let quantity = itemSnap.childSnapshot(forPath: "quantity").value as? Int ?? 0
                    let price = itemSnap.childSnapshot(forPath: "foodPrice").value as? Double ?? 0.0

                    items.append(AdminOrderItem(image: foodImage, desc: foodDesc, quantity: quantity, price: price))
                }

                let status = orderSnap.childSnapshot(forPath: "payment/status").value as? String ?? ""
                let total = orderSnap.childSnapshot(forPath: "payment/total").value as? String ?? ""
                let method = orderSnap.childSnapshot(forPath: "payment/method").value as? String ?? ""
                let placedAt = orderSnap.childSnapshot(forPath: "timestamps/placed").value as? String ?? ""
                let customerId = orderSnap.childSnapshot(forPath: "customerId").value as? String ?? ""

                let card = OrderCard(
                    id: orderId,
                    items: items,
                    status: status,
                    total: total,
                    method: method,
                    placedAt: placedAt,
                    customerId: customerId
                )
                loadedOrders.append(card)
            }

            orders = loadedOrders
        }
    }
}

// MARK: - Models

struct OrderCard: Identifiable {
    var id: String
    var items: [AdminOrderItem]
    var status: String
    var total: String
    var method: String
    var placedAt: String
    var customerId: String
}

struct AdminOrderItem: Identifiable {
    let id = UUID()
    var image: String
    var desc: String
    var quantity: Int
    var price: Double
}

enum Tab: String {
    case dashboard = "Dashboard"
    case users = "Users"
    case approvals = "Approvals"
    case transaction = "Transactions"
    case settings = "Settings"
}

#Preview {
    TransactionView()
}
