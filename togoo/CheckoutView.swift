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
    @Environment(\.presentationMode) private var presentationMode

    @State var checkoutItems: [CartItem]
    @State private var subtotal: Double = 0.0
    @State private var gst: Double = 0.0
    @State private var qst: Double = 0.0
    @State private var total: Double = 0.0

    private let GST_RATE = 0.05
    private let QST_RATE = 0.09975

    let primaryColor = Color(hex: "F18D34")
    let greenColor = Color(hex: "388E3C")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ✅ Custom back + title bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                    Spacer()
                    Text("Checkout")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Spacer().frame(width: 60) // for alignment
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                // ✅ Scrollable list of checkout items
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($checkoutItems) { $item in
                            CheckoutItemRow(cartItem: $item, onQuantityChanged: calculateTotal)
                        }
                        .onDelete(perform: deleteItems)

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Divider()

                // ✅ Static bottom section
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
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

                    HStack(spacing: 12) {
                        Button(action: proceedToPayment) {
                            Text("Proceed to Payment")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(greenColor)
                                .cornerRadius(8)
                        }

                        NavigationLink(destination: CustomerHomeView()) {
                            Text("Cancel Order")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryColor)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationBarBackButtonHidden(true)
            .onAppear(perform: calculateTotal)
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
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(checkoutItems: [
            CartItem(foodId: "Burger", foodDescription: "Juicy Burger", foodImage: "https://example.com/burger.jpg", foodPrice: 7.99, quantity: 2),
            CartItem(foodId: "Pizza", foodDescription: "Cheesy Pepperoni", foodImage: "https://example.com/pizza.jpg", foodPrice: 10.99, quantity: 1)
        ])
    }
}
