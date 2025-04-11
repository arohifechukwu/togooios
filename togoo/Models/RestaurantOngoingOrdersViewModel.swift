//
//  RestaurantOngoingOrdersViewModel.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct OngoingOrder: Identifiable, Equatable {
    var id: String { orderId }
    let orderId: String
    let customerName: String
    var status: String
    let driverName: String?
}

class RestaurantOngoingOrdersViewModel: ObservableObject {
    @Published var ongoingOrders: [OngoingOrder] = []
    @Published var availableDriverCount = 0
    @Published var searchQuery = ""
    @Published var filterBy = "Order ID"

    private let db = Database.database().reference()
    private var orderListeners: [String: DatabaseHandle] = [:]

    init() {
        fetchDriverCount()
        fetchOngoingOrders()
    }

    func fetchDriverCount() {
        db.child("driver").observe(.value) { snapshot in
            var count = 0
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let availability = snap.childSnapshot(forPath: "availability").value as? String,
                   availability.lowercased() == "available" {
                    count += 1
                }
            }
            DispatchQueue.main.async {
                self.availableDriverCount = count
            }
        }
    }

    func fetchOngoingOrders() {
        guard let restaurantId = Auth.auth().currentUser?.uid else { return }
        let ref = db.child("ordersByRestaurant").child(restaurantId)

        ref.observe(.value) { snapshot in
            self.ongoingOrders.removeAll()
            self.orderListeners.values.forEach { self.db.removeObserver(withHandle: $0) }
            self.orderListeners.removeAll()

            for case let snap as DataSnapshot in snapshot.children {
                self.listenToOrder(orderId: snap.key)
            }
        }
    }

    private func listenToOrder(orderId: String) {
        let handle = db.child("orders").child(orderId).observe(.value) { snap in
            guard let status = snap.childSnapshot(forPath: "status").value as? String,
                  status != "delivered" && status != "declined",
                  let customer = snap.childSnapshot(forPath: "customer").value as? [String: Any],
                  let name = customer["name"] as? String else { return }

            let driver = snap.childSnapshot(forPath: "driver").value as? [String: Any]
            let driverName = driver?["name"] as? String

            let order = OngoingOrder(
                orderId: orderId,
                customerName: name,
                status: status,
                driverName: driverName
            )

            DispatchQueue.main.async {
                self.ongoingOrders.removeAll { $0.orderId == orderId }
                self.ongoingOrders.append(order)
            }
        }

        orderListeners[orderId] = handle
    }

    func updateStatus(orderId: String, to newStatus: String) {
        let now = ISO8601DateFormatter().string(from: Date())
        var updates: [String: Any] = [
            "status": newStatus,
            "updateLogs": [UUID().uuidString: [
                "status": newStatus,
                "note": "Status updated to \(newStatus) by restaurant.",
                "timestamp": now
            ]]
        ]

        let timeKey: String? = switch newStatus {
        case "preparing": "timestamps/preparing"
        case "ready": "timestamps/readyForPickup"
        default: nil
        }

        if let k = timeKey {
            updates[k] = now
        }

        db.child("orders").child(orderId).updateChildValues(updates) { _, _ in
            DispatchQueue.main.async {
                if let index = self.ongoingOrders.firstIndex(where: { $0.orderId == orderId }) {
                    self.ongoingOrders[index].status = newStatus
                }
            }
        }
    }

    var filteredOrders: [OngoingOrder] {
        ongoingOrders.filter {
            switch filterBy {
            case "Order ID": $0.orderId.lowercased().contains(searchQuery.lowercased())
            case "Customer": $0.customerName.lowercased().contains(searchQuery.lowercased())
            case "Status": $0.status.lowercased().contains(searchQuery.lowercased())
            default: true
            }
        }
    }
}
