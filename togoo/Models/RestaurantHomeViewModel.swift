//
//  RestaurantHomeViewModel.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import Foundation
import FirebaseDatabase
import FirebaseAuth

struct PlacedOrder {
    let orderId: String
    let customerName: String
    let customerPhone: String
    let customerAddress: String
    let foodId: String
    let foodDescription: String
    let foodPrice: String
    let quantity: String
    let total: String
    let paymentMethod: String
    let notes: String
    let status: String
}

class RestaurantHomeViewModel: ObservableObject {
    @Published var placedOrders: [PlacedOrder] = []
    private var orderListeners: [String: DatabaseHandle] = [:]

    private let db = Database.database().reference()

    init() {
        fetchOrderIds()
    }

    func fetchOrderIds() {
        guard let restaurantId = Auth.auth().currentUser?.uid else { return }
        let ref = db.child("ordersByRestaurant").child(restaurantId)

        ref.observe(.value) { snapshot in
            self.placedOrders.removeAll()

            // ✅ Remove all previous listeners with orderId reference
            for (orderId, handle) in self.orderListeners {
                self.db.child("orders").child(orderId).removeObserver(withHandle: handle)
            }

            self.orderListeners.removeAll() // clean the dictionary

            snapshot.children.forEach { child in
                if let snap = child as? DataSnapshot {
                    self.listenToOrder(orderId: snap.key)
                }
            }
        }
    }

    func listenToOrder(orderId: String) {
        let handle = db.child("orders").child(orderId).observe(.value) { snap in
            // ✅ Check if order no longer exists or status is not "placed"
            if !snap.exists() || snap.childSnapshot(forPath: "status").value as? String != "placed" {
                DispatchQueue.main.async {
                    self.placedOrders.removeAll { $0.orderId == orderId }
                }
                return
            }

            guard let customer = snap.childSnapshot(forPath: "customer").value as? [String: Any],
                  let name = customer["name"] as? String,
                  let phone = customer["phone"] as? String,
                  let address = customer["address"] as? String else { return }

            let item = snap.childSnapshot(forPath: "orderDetails/items/0")
            let foodId = item.childSnapshot(forPath: "foodId").value as? String ?? "N/A"
            let description = item.childSnapshot(forPath: "foodDescription").value as? String ?? "N/A"
            let foodPrice = "\(item.childSnapshot(forPath: "foodPrice").value ?? "0")"
            let quantity = "\(item.childSnapshot(forPath: "quantity").value ?? "1")"

            let payment = snap.childSnapshot(forPath: "payment")
            let total = "\(payment.childSnapshot(forPath: "total").value ?? "0")"
            let method = payment.childSnapshot(forPath: "method").value as? String ?? "N/A"
            let notes = snap.childSnapshot(forPath: "notes").value as? String ?? "None"

            let order = PlacedOrder(
                orderId: orderId,
                customerName: name,
                customerPhone: phone,
                customerAddress: address,
                foodId: foodId,
                foodDescription: description,
                foodPrice: foodPrice,
                quantity: quantity,
                total: total,
                paymentMethod: method,
                notes: notes,
                status: "placed"
            )

            DispatchQueue.main.async {
                self.placedOrders.removeAll { $0.orderId == orderId }
                self.placedOrders.append(order)
            }
        }

        orderListeners[orderId] = handle
    }

//    func updateOrderStatus(orderId: String, newStatus: String) {
//        let now = ISO8601DateFormatter().string(from: Date())
//        var updates: [String: Any] = [
//            "status": newStatus,
//            "updateLogs": [UUID().uuidString: [
//                "status": newStatus,
//                "note": "Status updated to \(newStatus) by restaurant.",
//                "timestamp": now
//            ]]
//        ]
//
//        let timestampKey: String? = {
//            switch newStatus {
//            case "accepted": return "timestamps/restaurantAccepted"
//            case "declined": return "timestamps/restaurantDeclined"
//            case "preparing": return "timestamps/preparing"
//            case "ready": return "timestamps/readyForPickup"
//            default: return nil
//            }
//        }()
//
//        if let key = timestampKey {
//            updates[key] = now
//        }
//
//        db.child("orders").child(orderId).updateChildValues(updates)
//    }
    
    func updateOrderStatus(orderId: String, newStatus: String) {
        let now = ISO8601DateFormatter().string(from: Date())

        // Step 1: Update status and timestamp
        var updates: [String: Any] = [
            "status": newStatus
        ]

        let timestampKey: String? = {
            switch newStatus {
            case "accepted": return "timestamps/restaurantAccepted"
            case "declined": return "timestamps/restaurantDeclined"
            case "preparing": return "timestamps/preparing"
            case "ready": return "timestamps/readyForPickup"
            default: return nil
            }
        }()

        if let key = timestampKey {
            updates[key] = now
        }

        db.child("orders").child(orderId).updateChildValues(updates)

        // Step 2: Add a new log entry under updateLogs using childByAutoId
        let logEntry: [String: Any] = [
            "status": newStatus,
            "note": "Status updated to \(newStatus) by restaurant.",
            "timestamp": now
        ]

        db.child("orders").child(orderId).child("updateLogs").childByAutoId().setValue(logEntry)
    }

    func notifyDrivers(order: PlacedOrder) {
        db.child("driver").observeSingleEvent(of: .value) { snapshot in
            for driver in snapshot.children {
                guard let snap = driver as? DataSnapshot,
                      let availability = snap.childSnapshot(forPath: "availability").value as? String,
                      availability.lowercased() == "available" else { continue }

                let notification: [String: Any] = [
                    "orderId": order.orderId,
                    "address": order.customerAddress,
                    "phone": order.customerPhone,
                    "status": "awaiting_driver"
                ]

                self.db.child("driver").child(snap.key).child("notifications").childByAutoId().setValue(notification)
            }
        }
    }
    
    
    deinit {
        for (orderId, handle) in orderListeners {
            db.child("orders").child(orderId).removeObserver(withHandle: handle)
        }
    }
}

