//
//  RestaurantOngoingOrdersView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI

struct RestaurantOngoingOrdersView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = RestaurantOngoingOrdersViewModel()

    let filters = ["Order ID", "Customer", "Status"]

    var body: some View {
        VStack(spacing: 0) {
            // Custom Toolbar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(.trailing, 4)
                }

                Text("Ongoing Orders")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(Color.primaryVariant)

            // Filter & Search
            HStack(spacing: 12) {
                Picker("Filter", selection: $viewModel.filterBy) {
                    ForEach(filters, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.leading)

                TextField("Search...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
            }
            .padding(.vertical, 8)

            // Orders List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.filteredOrders) { order in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Order: \(order.orderId)").bold()
                            Text("Customer: \(order.customerName)")
                            Text("Status: \(order.status.capitalized)")

                            if let driver = order.driverName {
                                Text("Driver: \(driver)")
                                    .foregroundColor(.blue)
                            } else {
                                Text("Driver: \(viewModel.availableDriverCount) drivers available")
                                    .foregroundColor(.darkGray)
                            }

                            HStack {
                                if order.status == "accepted" {
                                    Button("Preparing") {
                                        viewModel.updateStatus(orderId: order.orderId, to: "preparing")
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Ready") {
                                        viewModel.updateStatus(orderId: order.orderId, to: "ready")
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else if order.status == "preparing" {
                                    Button("Preparing ✅") {}
                                        .buttonStyle(.bordered)
                                        .disabled(true)

                                    Button("Ready") {
                                        viewModel.updateStatus(orderId: order.orderId, to: "ready")
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else if order.status == "ready" {
                                    Text("✅ Ready")
                                        .foregroundColor(.green)
                                        .padding(.vertical, 4)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
    }
}
