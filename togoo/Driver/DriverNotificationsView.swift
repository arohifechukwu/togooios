//
//  DriverNotificationsView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct DriverNotificationsView: View {
    @State private var notifications: [DriverNotification] = []
    @State private var isOffline = false
    @State private var destinationView: AnyView? = nil
    @State private var navigate = false
    private var driverId: String { Auth.auth().currentUser?.uid ?? "" }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Notifications")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryVariant)

                ScrollView {
                    VStack(spacing: 16) {
                        if isOffline {
                            Text("You're currently offline. Update your availability to view your notifications.")
                                .foregroundColor(.gray)
                                .padding()
                                .multilineTextAlignment(.center)
                        } else if notifications.isEmpty {
                            Text("No available notifications.")
                                .foregroundColor(.gray)
                                .padding()
                                .multilineTextAlignment(.center)
                        } else {
                            ForEach(notifications, id: \.id) { notification in
                                MaterialCardsView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Order ID: \(notification.orderId)")
                                                .font(.headline)
                                                .foregroundColor(.black)

                                            Text("Status: \(notification.status)")
                                                .foregroundColor(.black)

                                            Text("Customer: \(notification.customerName)")
                                                .foregroundColor(.black)
                                            
                                            Text("Address: \(notification.customerAddress)")
                                                .foregroundColor(.black)

                                            Text("Phone: \(notification.customerPhone)")
                                                .foregroundColor(.black)
                                        }

                                        Divider()

                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                deleteNotification(notification)
                                            }) {
                                                Text("Delete")
                                                    .frame(minWidth: 80)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                DriverBottomNavItem(selectedTab: "notifications") { selected in
                    destinationView = selected
                    navigate = true
                }
            }
            .navigationDestination(isPresented: $navigate) {
                destinationView
            }
            .onAppear {
                checkAvailabilityAndLoadNotifications()
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }

    // ✅ Availability Logic
    func checkAvailabilityAndLoadNotifications() {
        let availabilityRef = Database.database().reference()
            .child("driver")
            .child(driverId)
            .child("availability")

        availabilityRef.observeSingleEvent(of: .value) { snapshot in
            let availability = snapshot.value as? String ?? ""
            if availability.lowercased() != "available" {
                isOffline = true
            } else {
                loadNotifications()
            }
        }
    }

    // ✅ Load Notifications from Firebase
    func loadNotifications() {
        let notifRef = Database.database().reference()
            .child("driver")
            .child(driverId)
            .child("notifications")

        notifRef.observe(.value) { snapshot in
            var loaded: [DriverNotification] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let data = snap.value as? [String: Any],
                   let orderId = data["orderId"] as? String,
                   let status = data["status"] as? String,
                   status.lowercased() != "order accepted" {

                    let orderRef = Database.database().reference().child("orders").child(orderId)
                    orderRef.observeSingleEvent(of: .value) { orderSnap in
                        let customerName = orderSnap.childSnapshot(forPath: "customer/name").value as? String ?? "Unknown"
                        let customerAddress = orderSnap.childSnapshot(forPath: "customer/address").value as? String ?? "Unknown"
                        let customerPhone = orderSnap.childSnapshot(forPath: "customer/phone").value as? String ?? "N/A"

                        let notif = DriverNotification(
                            id: snap.key,
                            orderId: orderId,
                            status: status,
                            customerName: customerName,
                            customerAddress: customerAddress,
                            customerPhone: customerPhone
                        )

                        DispatchQueue.main.async {
                            loaded.append(notif)
                            self.notifications = loaded.sorted { $0.orderId > $1.orderId }
                        }
                    }
                }
            }

            if snapshot.childrenCount == 0 {
                self.notifications = []
            }
        }
    }

    // ✅ Delete notification
    func deleteNotification(_ notification: DriverNotification) {
        let ref = Database.database().reference()
            .child("driver")
            .child(driverId)
            .child("notifications")
            .child(notification.id)

        ref.removeValue()
    }
}

// ✅ Updated Model
struct DriverNotification {
    let id: String
    let orderId: String
    let status: String
    let customerName: String
    let customerAddress: String
    let customerPhone: String
}


struct DriverNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        DriverNotificationsView()
    }
}

