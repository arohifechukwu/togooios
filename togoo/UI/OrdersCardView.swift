//
//  OrdersCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-14.
//


import SwiftUI
import FirebaseDatabase

struct OrdersCardView: View {
    let order: OrderCard
    @State private var customerName: String = ""
    @State private var customerPhone: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{1F4C5} Order ID: \(order.id)")
                .font(.subheadline.bold())

            ForEach(order.items) { item in
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: item.image)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.desc).font(.subheadline)
                        Text("Qty: \(item.quantity)").font(.caption)
                        Text("Unit Price: $\(String(format: "%.2f", item.price))").font(.caption)
                    }
                }
            }

            Text("Status: \(order.status)")
                .font(.subheadline)
                .foregroundColor(statusColor)

            Text("Total: $\(order.total)").font(.caption)
            Text("Payment Method: \(order.method)").font(.caption)
            Text("Placed At: \(order.placedAt)").font(.caption)

            if !customerName.isEmpty {
                Text("\u{1F464} Customer: \(customerName)").font(.caption)
                Text("\u{1F4DE} Phone: \(customerPhone)").font(.caption)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
        .onAppear {
            loadCustomerInfo()
        }
    }

    private var statusColor: Color {
        switch order.status.lowercased() {
        case "delivered": return .green
        case "pending": return .orange
        default: return .red
        }
    }

    private func loadCustomerInfo() {
        guard !order.customerId.isEmpty else { return }
        Database.database().reference().child("users").child(order.customerId)
            .observeSingleEvent(of: .value) { snapshot in
                customerName = snapshot.childSnapshot(forPath: "username").value as? String ?? ""
                customerPhone = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            }
    }
}