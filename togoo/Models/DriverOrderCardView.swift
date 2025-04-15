//
//  DriverOrderCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct DriverOrderCard: View {
    let orderId: String
    let order: DriverOrder
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        MaterialCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Order ID: \(orderId)")
                    .font(.headline)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Status: \(order.status)")
                    Text("Customer: \(order.customerName)")
                    Text("Address: \(order.customerAddress)")
                    Text("Phone: \(order.customerPhone)")
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pickup: \(order.restaurantName)")
                    Text("Food: \(order.foodDescription)")
                    Text("Payment: \(order.paymentStatus)")
                }

                HStack {
                    Spacer()
                    Button("Accept", action: onAccept)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                    Button("Decline", action: onDecline)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                }
                .padding(.top, 8)
            }
            .font(.subheadline)
            .foregroundColor(.black)
            .padding()
        }
        .padding(.horizontal)
    }
}


struct DriverOrder: Identifiable {
    let id: String
    let status: String
    let customerName: String
    let customerAddress: String
    let customerPhone: String
    let restaurantName: String
    let restaurantAddress: String
    let foodId: String
    let foodDescription: String
    let quantity: String
    let deliveryFare: String
    let tips: String
    let total: String
    let paymentMethod: String
    let paymentStatus: String

    init?(id: String, data: [String: Any]) {
        guard let status = data["status"] as? String,
              let cust = data["customer"] as? [String: Any],
              let rest = data["restaurant"] as? [String: Any],
              let details = (data["orderDetails"] as? [String: Any])?["items"] as? [[String: Any]],
              let payment = data["payment"] as? [String: Any] else { return nil }

        let item = details.first ?? [:]

        self.id = id
        self.status = status
        self.customerName = cust["name"] as? String ?? ""
        self.customerAddress = cust["address"] as? String ?? ""
        self.customerPhone = cust["phone"] as? String ?? ""
        self.restaurantName = rest["name"] as? String ?? ""
        self.restaurantAddress = rest["address"] as? String ?? ""
        self.foodId = item["foodId"] as? String ?? ""
        self.foodDescription = item["foodDescription"] as? String ?? ""
        self.quantity = String(describing: item["quantity"] ?? "1")
        self.deliveryFare = String(describing: payment["deliveryFare"] ?? "")
        self.tips = String(describing: payment["tips"] ?? "")
        self.total = String(describing: payment["total"] ?? "")
        self.paymentMethod = payment["method"] as? String ?? ""
        self.paymentStatus = payment["status"] as? String ?? ""
    }
}

struct DriverInfo {
    let id: String
    let name: String
    let phone: String
    let address: String
}

func updateOrderStatus(orderId: String, status: String, note: String) {
    let ref = Database.database().reference().child("orders").child(orderId)
    let now = ISO8601DateFormatter().string(from: Date())

    var updates: [String: Any] = ["status": status]
    if status == "declined" {
        updates["timestamps/driverDeclined"] = now
    }

    ref.updateChildValues(updates)
    ref.child("updateLogs").childByAutoId().setValue([
        "timestamp": now,
        "status": status,
        "note": note
    ])
}

func assignDriverToOrder(orderId: String, driver: DriverInfo) {
    let now = ISO8601DateFormatter().string(from: Date())
    let orderRef = Database.database().reference().child("orders").child(orderId)

    orderRef.updateChildValues([
        "status": "out for delivery",
        "timestamps/driverAssigned": now,
        "driver": [
            "id": driver.id,
            "name": driver.name,
            "phone": driver.phone,
            "assignmentTimestamp": now
        ]
    ])

    orderRef.child("updateLogs").childByAutoId().setValue([
        "timestamp": now,
        "status": "out for delivery",
        "note": "Assigned to driver."
    ])

    Database.database().reference().child("ordersByDriver")
        .child(driver.id).child(orderId).setValue(true)

    let notifRef = Database.database().reference()
        .child("driver/\(driver.id)/notifications")

    notifRef.queryOrdered(byChild: "orderId").queryEqual(toValue: orderId)
        .observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                child.ref.child("status").setValue("order accepted")
            }
        }
}


