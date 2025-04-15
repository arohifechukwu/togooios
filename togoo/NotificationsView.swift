//
//  NotificationsView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var orderLogs: [OrderLog] = []
    @State private var showRatingDialog = false
    @State private var selectedOrder: OrderLog?
    @State private var showDriverInfo = false
    @State private var selectedDriverId: String?
    @State private var estimatedTime: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.primaryVariant)

            // Notifications List
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if orderLogs.isEmpty {
                        Text("No orders yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 32)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(orderLogs) { order in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Order ID: \(order.orderId)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)

                                ForEach(order.groupedLogs.keys.sorted(by: >), id: \.self) { date in
                                    Text("📅 \(date)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)

                                    ForEach(order.groupedLogs[date] ?? [], id: \.timestamp) { log in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(log.status): \(log.note)")
                                                .font(.body)
                                            Text(log.timestamp)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }

                                if order.status.lowercased() == "delivered" {
                                    Button("Rate Your Order") {
                                        selectedOrder = order
                                        showRatingDialog = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .padding(.top, 8)
                                }

                                if let driverId = order.driverId, !driverId.isEmpty {
                                    Button("Know Your Driver") {
                                        selectedDriverId = driverId
                                        estimatedTime = order.estimatedTime ?? ""
                                        showDriverInfo = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.orange)
                                    .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: fetchOrderLogs)
        .sheet(isPresented: $showRatingDialog) {
            if let order = selectedOrder {
                RatingDialog(order: order)
            }
        }
        .sheet(isPresented: $showDriverInfo) {
            if let driverId = selectedDriverId {
                DriverInfoDialog(driverId: driverId, estimatedTime: estimatedTime)
            }
        }
    }

    // MARK: - Data Models

    struct OrderLog: Identifiable {
        let id = UUID()
        let orderId: String
        let status: String
        let driverId: String?
        let estimatedTime: String?
        let groupedLogs: [String: [LogEntry]]
    }

    struct LogEntry {
        let status: String
        let note: String
        let timestamp: String
    }

    // MARK: - Data Fetching

    private func fetchOrderLogs() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ordersRef = Database.database().reference().child("ordersByCustomer").child(userId)

        ordersRef.observe(.value) { snapshot in
            var fetchedLogs: [OrderLog] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    let orderId = snap.key
                    fetchOrderDetails(orderId: orderId) { orderLog in
                        if let orderLog = orderLog {
                            fetchedLogs.append(orderLog)
                            orderLogs = fetchedLogs.sorted { $0.orderId > $1.orderId }
                        }
                    }
                }
            }
        }
    }

    private func fetchOrderDetails(orderId: String, completion: @escaping (OrderLog?) -> Void) {
        let orderRef = Database.database().reference().child("orders").child(orderId)

        orderRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(nil)
                return
            }

            let status = snapshot.childSnapshot(forPath: "status").value as? String ?? ""
            let driverId = snapshot.childSnapshot(forPath: "driver/id").value as? String
            let estimatedTime = snapshot.childSnapshot(forPath: "estimatedDeliveryTime").value as? String

            var logs: [LogEntry] = []
            let logsSnap = snapshot.childSnapshot(forPath: "updateLogs")

            for child in logsSnap.children {
                if let logSnap = child as? DataSnapshot {
                    let status = logSnap.childSnapshot(forPath: "status").value as? String ?? ""
                    let note = logSnap.childSnapshot(forPath: "note").value as? String ?? ""
                    let timestamp = logSnap.childSnapshot(forPath: "timestamp").value as? String ?? ""
                    logs.append(LogEntry(status: status, note: note, timestamp: timestamp))
                }
            }

            let grouped = Dictionary(grouping: logs) { log -> String in
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: log.timestamp) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    return dateFormatter.string(from: date)
                }
                return "Unknown Date"
            }

            let orderLog = OrderLog(orderId: orderId, status: status, driverId: driverId, estimatedTime: estimatedTime, groupedLogs: grouped)
            completion(orderLog)
        }
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
