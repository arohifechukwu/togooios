//
//  CheckoutView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss

    @State var checkoutItems: [CartItem]
    @State private var subtotal: Double = 0.0
    @State private var gst: Double = 0.0
    @State private var qst: Double = 0.0
    @State private var total: Double = 0.0

    private let GST_RATE = 0.05
    private let QST_RATE = 0.09975

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ✅ Custom Top Bar with safe area fix
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(60)
                                .background(Color.primaryColor)
                                .clipShape(Circle())
                        }
                        Text("Checkout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                .background(Color.primaryColor)
                .ignoresSafeArea(edges: .top) // ✅ Clean background to the top

                ScrollView {
                    VStack(spacing: 0) {
                        // 🛒 Checkout List
                        VStack(spacing: 0) {
                            ForEach($checkoutItems) { $item in
                                CheckoutItemRow(cartItem: $item, onQuantityChanged: calculateTotal)
                            }
                            .onDelete(perform: deleteItems)
                        }

                        // 🧾 Price Summary
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text("$\(subtotal, specifier: "%.2f")")
                            }
                            HStack {
                                Text("GST (5%)")
                                Spacer()
                                Text("$\(gst, specifier: "%.2f")")
                            }
                            HStack {
                                Text("QST (9.975%)")
                                Spacer()
                                Text("$\(qst, specifier: "%.2f")")
                            }
                            Divider()
                            HStack {
                                Text("Total")
                                    .fontWeight(.bold)
                                Spacer()
                                Text("$\(total, specifier: "%.2f")")
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))

                        // 🟢 Action Buttons
                        HStack(spacing: 12) {
                            Button(action: proceedToPayment) {
                                Text("Proceed to Payment")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.holoGreenDark)
                                    .cornerRadius(8)
                            }

                            NavigationLink(destination: CustomerHomeView()) {
                                Text("Cancel Order")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryColor)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }
                .onAppear(perform: calculateTotal)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func calculateTotal() {
        subtotal = checkoutItems.reduce(0) { $0 + ($1.foodPrice * Double($1.quantity)) }
        gst = subtotal * GST_RATE
        qst = subtotal * QST_RATE
        total = subtotal + gst + qst
    }

    private func deleteItems(at offsets: IndexSet) {
        checkoutItems.remove(atOffsets: offsets)
        calculateTotal()
    }

    private func proceedToPayment() {
        print("Proceeding to payment with \(checkoutItems.count) items.")
    }

    private func cancelOrder() {
        dismiss()
    }
}

extension Color {
    static let primaryColor = Color(hex: "#F18D34")
    static let holoGreenDark = Color(hex: "#388E3C") // Android Holo Green Dark
}


struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(checkoutItems: [
            CartItem(foodId: "Cheeseburger",
                     foodDescription: "A delicious cheeseburger",
                     foodImage: "https://example.com/cheeseburger.jpg",
                     foodPrice: 5.99,
                     quantity: 2),
            CartItem(foodId: "Pepperoni Pizza",
                     foodDescription: "Spicy pepperoni pizza",
                     foodImage: "https://example.com/pepperoni.jpg",
                     foodPrice: 8.99,
                     quantity: 1)
        ])
    }
}
