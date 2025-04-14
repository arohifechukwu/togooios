//
//  DriverHomeView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

struct DriverHomeView: View {
    @State private var availability: String = "unavailable"
    @State private var orders: [DriverOrder] = []
    @State private var driverInfo: DriverInfo? = nil
    @State private var navigateToDelivery: String? = nil
    @State private var activeOrderId: String? = nil
    @State private var showMessage: String = ""
    @State private var destinationView: AnyView? = nil
    @State private var navigate = false
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Available Orders")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.primaryVariant)
                
                // 🧭 View Active Trip
                if availability.lowercased() == "available", let activeOrderId = activeOrderId {
                    Button("View Active Trip") {
                        checkIfTripStillActive(for: activeOrderId)
                    }
                    .font(.subheadline)
                    .padding()
                    .foregroundColor(.primaryVariant)
                }
                
                if !showMessage.isEmpty {
                    Text(showMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 6)
                }
                
                // 🟡 Availability Logic
                if availability.lowercased() != "available" {
                    Text("Orders cannot be assigned while offline. Update your availability.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if orders.isEmpty {
                    Text("No available orders.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(orders) { order in
                                if let driver = driverInfo {
                                    DriverOrderCard(
                                        orderId: order.id,
                                        order: order,
                                        onAccept: {
                                            assignDriverToOrder(orderId: order.id, driver: driver)
                                            navigateToDelivery = order.id
                                        },
                                        onDecline: {
                                            updateOrderStatus(orderId: order.id, status: "declined", note: "Declined by driver.")
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                
                Spacer()
                
                DriverBottomNavItem(selectedTab: "orders") { selected in
                    destinationView = selected
                    navigate = true
                }
                .onAppear {
                    loadDriverInfo()
                    checkActiveTrip()
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: Binding(
                    get: { navigateToDelivery != nil },
                    set: { if !$0 { navigateToDelivery = nil } }
                )) {
                    if let orderId = navigateToDelivery {
                        DriverDeliveryView(orderId: orderId)
                    }
                }
                .navigationDestination(isPresented: $navigate) {
                    if let view = destinationView {
                        view
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    // 🔄 Load Driver Info
    private func loadDriverInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let driverRef = Database.database().reference().child("driver").child(uid)
        driverRef.observeSingleEvent(of: .value) { snapshot in
            availability = snapshot.childSnapshot(forPath: "availability").value as? String ?? "unavailable"
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let phone = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            let address = snapshot.childSnapshot(forPath: "address").value as? String ?? ""
            self.driverInfo = DriverInfo(id: uid, name: name, phone: phone, address: address)

            if availability.lowercased() == "available" {
                loadOrders()
            }
        }
    }

    // 📦 Load Available Orders
    private func loadOrders() {
        let ref = Database.database().reference().child("orders")
        ref.queryOrdered(byChild: "status").queryEqual(toValue: "ready").observe(.value) { snapshot in
            var fetched: [DriverOrder] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   !snap.hasChild("driver"),
                   let value = snap.value as? [String: Any],
                   let order = DriverOrder(id: snap.key, data: value) {
                    fetched.append(order)
                }
            }
            self.orders = fetched
        }
    }

    // 👀 Check if driver has an active trip
    private func checkActiveTrip() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let activeRef = Database.database().reference().child("ordersByDriver").child(uid)
        activeRef.observeSingleEvent(of: .value) { snapshot in
            if let first = snapshot.children.allObjects.first as? DataSnapshot {
                self.activeOrderId = first.key
            }
        }
    }
    
    private func checkIfTripStillActive(for orderId: String) {
        let ref = Database.database().reference().child("orders").child(orderId)
        ref.observeSingleEvent(of: .value) { snapshot in
            let status = snapshot.childSnapshot(forPath: "status").value as? String ?? ""
            if status == "out for delivery" {
                navigateToDelivery = orderId
            } else {
                showMessage = "No active trip at the moment."
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showMessage = ""
                }
            }
        }
    }
}


#Preview {
    DriverHomeView()
}
