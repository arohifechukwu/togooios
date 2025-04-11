//
//  RestaurantOrderCard.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct RestaurantOrderCard: View {
    var order: PlacedOrder
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text("Order ID: \(order.orderId)")
                Text("Customer: \(order.customerName)")
                Text("Phone: \(order.customerPhone)")
                Text("Address: \(order.customerAddress)")
                Text("Food ID: \(order.foodId)")
                Text("Description: \(order.foodDescription)")
                Text("Price: $\(order.foodPrice)")
                Text("Quantity: \(order.quantity)")
                Text("Total: $\(order.total)")
                Text("Payment: \(order.paymentMethod)")
                Text("Notes: \(order.notes)")
                Text("Status: \(order.status.capitalized)")
            }
            .font(.subheadline)

            HStack {
                Button("Decline", action: onDecline)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                Button("Accept", action: onAccept)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            }
            .padding(.top, 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}