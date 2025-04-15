//
//  OrderCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI

struct OrderCardView: View {
    var order: Order
    var onKnowDriver: () -> Void
    var onRateOrder: () -> Void
    var onLogComplaint: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📅 Order ID: \(order.id)")
                .font(.headline)

            Divider()

            Text("Activity Updates")
                .font(.subheadline)
                .foregroundColor(.blue)

            ForEach(order.updateLogs) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(log.status): \(log.note)")
                        .font(.body)
                    Text(log.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            Text("Order Summary")
                .font(.subheadline)
                .foregroundColor(.blue)

            ForEach(order.orderItems) { item in
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: item.foodImage)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• \(item.id)")
                        Text(item.foodDescription)
                        Text("Qty: \(item.quantity)")
                        Text("Unit Price: $\(String(format: "%.2f", item.price))")
                    }
                }
            }

            Divider()

            Group {
                Text("Payment Method: \(order.payment.method ?? "N/A")")
                Text("Tips: $\(String(format: "%.2f", order.payment.tips ?? 0))")
                Text("Subtotal: $\(String(format: "%.2f", order.payment.subtotalBeforeTax ?? 0))")
                Text("Delivery Fee: $\(String(format: "%.2f", order.payment.deliveryFare ?? 0))")
                Text("Total: $\(String(format: "%.2f", order.payment.total ?? 0))")
                Text("Status: \(order.status.capitalized)")
                Text("Transaction Ref: \(order.payment.transactionId ?? "N/A")")
                Text("📆 Placed: \(order.timestamps.placed ?? "N/A")")
                Text("🏃 Delivered: \(order.timestamps.delivered ?? "N/A")")
                Text("✍️ Notes: \(order.notes ?? "None")")
            }

            if let name = order.restaurantName {
                Text("🍽 Restaurant: \(name)")
            }

            if let address = order.restaurantAddress {
                Text("📍 Address: \(address)")
            }

            if let driverName = order.driverName {
                Text("🚚 Driver: \(driverName)")
            }

            if let phone = order.driverPhone {
                Text("📞 Phone: \(phone)")
            }

            if let car = order.driverCarModel {
                Text("🚗 Car: \(car)")
            }

            if let driverId = order.driverId, !driverId.isEmpty {
                Button("Know Your Driver", action: onKnowDriver)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryVariant)
            }

            if order.status == "delivered" {
                Button("Rate Your Order", action: onRateOrder)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryVariant)

                Button("Log A Complaint", action: onLogComplaint)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryVariant)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 8)
    }
}
