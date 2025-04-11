//
//  OrderViewModel.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//



import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

// MARK: - Models

struct Order: Identifiable {
    var id: String
    var restaurantId: String?
    var restaurantName: String?
    var restaurantAddress: String?
    var driverId: String?
    var driverName: String?
    var driverPhone: String?
    var driverCarModel: String?
    var estimatedDeliveryTime: String?
    var status: String
    var updateLogs: [OrderUpdateLog]
    var orderItems: [OrderItem]
    var payment: PaymentDetails
    var timestamps: Timestamps
    var notes: String?
}

struct OrderUpdateLog: Identifiable {
    var id = UUID()
    var status: String
    var note: String
    var timestamp: String
}

struct OrderItem: Identifiable {
    var id: String   // foodId
    var foodDescription: String
    var foodImage: String
    var quantity: Int
    var price: Double
}

struct PaymentDetails {
    var method: String?
    var tips: Double?
    var subtotalBeforeTax: Double?
    var deliveryFare: Double?
    var total: Double?
    var transactionId: String?
}

struct Timestamps {
    var placed: String?
    var delivered: String?
    var placedMillis: Int64?
}

// MARK: - View Model

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    let currentUserId: String
    
    init() {
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
        fetchOrders()
    }
    
    func fetchOrders() {
        let ordersRef = Database.database().reference().child("orders")
        // Query orders where "customer/id" equals the current user id.
        let query = ordersRef.queryOrdered(byChild: "customer/id").queryEqual(toValue: currentUserId)
        
        query.observeSingleEvent(of: .value) { snapshot in
            var orderList: [(orderId: String, placedMillis: Int64)] = []
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let orderId = child.key
                var placedMillis: Int64 = 0
                if let millisObj = child.childSnapshot(forPath: "timestamps/placedMillis").value {
                    placedMillis = Int64("\(millisObj)") ?? 0
                }
                orderList.append((orderId: orderId, placedMillis: placedMillis))
            }
            // Sort newest first
            orderList.sort { $0.placedMillis > $1.placedMillis }
            
            for order in orderList {
                self.fetchOrderDetails(orderId: order.orderId)
            }
        } withCancel: { error in
            print("Failed to load orders: \(error.localizedDescription)")
        }
    }
    
    func fetchOrderDetails(orderId: String) {
        let orderRef = Database.database().reference().child("orders").child(orderId)
        orderRef.observeSingleEvent(of: .value) { snapshot in
            let restaurantId = snapshot.childSnapshot(forPath: "restaurant/id").value as? String
            let restaurantName = snapshot.childSnapshot(forPath: "restaurant/name").value as? String
            let restaurantAddress = snapshot.childSnapshot(forPath: "restaurant/address").value as? String
            let driverId = snapshot.childSnapshot(forPath: "driver/id").value as? String
            let eta = snapshot.childSnapshot(forPath: "estimatedDeliveryTime").value as? String
            let status = (snapshot.childSnapshot(forPath: "status").value as? String ?? "").lowercased()
            let notes = snapshot.childSnapshot(forPath: "notes").value as? String

            let placed = snapshot.childSnapshot(forPath: "timestamps/placed").value as? String
            let delivered = snapshot.childSnapshot(forPath: "timestamps/delivered").value as? String
            let placedMillis = Int64("\(snapshot.childSnapshot(forPath: "timestamps/placedMillis").value ?? 0)") ?? 0
            let timestamps = Timestamps(placed: placed, delivered: delivered, placedMillis: placedMillis)

            var logs: [OrderUpdateLog] = []
            let logsSnap = snapshot.childSnapshot(forPath: "updateLogs")
            for logChild in logsSnap.children.allObjects as? [DataSnapshot] ?? [] {
                if let ts = logChild.childSnapshot(forPath: "timestamp").value as? String,
                   let stat = logChild.childSnapshot(forPath: "status").value as? String,
                   let note = logChild.childSnapshot(forPath: "note").value as? String {
                    logs.append(OrderUpdateLog(status: stat, note: note, timestamp: ts))
                }
            }
            logs.sort { $0.timestamp > $1.timestamp }

            var orderItems: [OrderItem] = []
            let itemsSnap = snapshot.childSnapshot(forPath: "orderDetails/items")
            for itemChild in itemsSnap.children.allObjects as? [DataSnapshot] ?? [] {
                let foodId = itemChild.childSnapshot(forPath: "foodId").value as? String ?? ""
                let description = itemChild.childSnapshot(forPath: "foodDescription").value as? String ?? ""
                let foodImage = itemChild.childSnapshot(forPath: "foodImage").value as? String ?? ""
                let quantity = Int("\(itemChild.childSnapshot(forPath: "quantity").value ?? "0")") ?? 0
                let price = Double("\(itemChild.childSnapshot(forPath: "foodPrice").value ?? "0")") ?? 0.0
                orderItems.append(OrderItem(id: foodId, foodDescription: description, foodImage: foodImage, quantity: quantity, price: price))
            }

            let paymentSnap = snapshot.childSnapshot(forPath: "payment")
            let paymentMethod = paymentSnap.childSnapshot(forPath: "method").value as? String
            let tips = Double("\(paymentSnap.childSnapshot(forPath: "tips").value ?? "0")") ?? 0.0
            let subtotal = Double("\(paymentSnap.childSnapshot(forPath: "subtotalBeforeTax").value ?? "0")") ?? 0.0
            let deliveryFare = Double("\(paymentSnap.childSnapshot(forPath: "deliveryFare").value ?? "0")") ?? 0.0
            let total = Double("\(paymentSnap.childSnapshot(forPath: "total").value ?? "0")") ?? 0.0
            let transactionId = paymentSnap.childSnapshot(forPath: "transactionId").value as? String

            let payment = PaymentDetails(method: paymentMethod, tips: tips, subtotalBeforeTax: subtotal, deliveryFare: deliveryFare, total: total, transactionId: transactionId)

            // 🔹 Fetch driver details separately
            if let driverId = driverId {
                let driverRef = Database.database().reference().child("driver").child(driverId)
                driverRef.observeSingleEvent(of: .value) { driverSnap in
                    let driverName = driverSnap.childSnapshot(forPath: "name").value as? String
                    let driverPhone = driverSnap.childSnapshot(forPath: "phone").value as? String
                    let carType = driverSnap.childSnapshot(forPath: "carType").value as? String ?? ""
                    let carModel = driverSnap.childSnapshot(forPath: "carModel").value as? String ?? ""
                    let driverCarModel = "\(carType) \(carModel)"

                    let order = Order(
                        id: orderId,
                        restaurantId: restaurantId,
                        restaurantName: restaurantName,
                        restaurantAddress: restaurantAddress,
                        driverId: driverId,
                        driverName: driverName,
                        driverPhone: driverPhone,
                        driverCarModel: driverCarModel,
                        estimatedDeliveryTime: eta,
                        status: status,
                        updateLogs: logs,
                        orderItems: orderItems,
                        payment: payment,
                        timestamps: timestamps,
                        notes: notes
                    )

                    DispatchQueue.main.async {
                        self.orders.append(order)
                    }
                }
            } else {
                let order = Order(
                    id: orderId,
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                    restaurantAddress: restaurantAddress,
                    driverId: nil,
                    driverName: nil,
                    driverPhone: nil,
                    driverCarModel: nil,
                    estimatedDeliveryTime: eta,
                    status: status,
                    updateLogs: logs,
                    orderItems: orderItems,
                    payment: payment,
                    timestamps: timestamps,
                    notes: notes
                )

                DispatchQueue.main.async {
                    self.orders.append(order)
                }
            
        } 
        }
    }
    
    // MARK: - Rating and Dispute Methods
    
    func updateRating(role: String, uid: String, customerId: String, rating: Float, comment: String) {
        let ratingData: [String: Any] = [
            "value": rating,
            "comment": comment,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        let ref = Database.database().reference().child(role).child(uid).child("ratings").child(customerId)
        ref.setValue(ratingData)
        updateAverageRating(role: role, uid: uid)
    }
    
    func updateAverageRating(role: String, uid: String) {
        let ratingsRef = Database.database().reference().child(role).child(uid).child("ratings")
        ratingsRef.observeSingleEvent(of: .value) { snapshot in
            var sum: Float = 0
            var count: Float = 0
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                if let value = child.childSnapshot(forPath: "value").value as? Float {
                    sum += value
                    count += 1
                }
            }
            let avg = count == 0 ? 0 : sum / count
            Database.database().reference().child(role).child(uid).child("rating").setValue(avg)
        }
    }
    
    func submitDispute(orderId: String, title: String, description: String, reason: String, imageURL: String?) {
        let disputeRef = Database.database().reference().child("orders").child(orderId).child("dispute")
        disputeRef.child("details/disputeTitle").setValue(title)
        disputeRef.child("details/description").setValue(description)
        if let img = imageURL {
            disputeRef.child("details/imageURL").setValue(img)
        }
        disputeRef.child("reason").setValue(reason)
        disputeRef.child("status").setValue("pending")
        let isoFormatter = ISO8601DateFormatter()
        disputeRef.child("timestamp").setValue(isoFormatter.string(from: Date()))
    }
    
    func uploadEvidence(orderId: String, title: String, description: String, reason: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("disputes").child(filename)
        storageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Image upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
}
