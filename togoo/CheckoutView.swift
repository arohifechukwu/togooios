
//
//  CartView.swift
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
    @State private var tips: Double = 0.0
    @State private var total: Double = 0.0
    @State private var selectedPaymentMethod: String = "Card"
    @State private var orderNote: String = ""
    @State private var navigateToPayment = false
    @State private var currentCustomer: Customer?
    @State private var currentRestaurant: Restaurant?

    private let GST_RATE = 0.05
    private let QST_RATE = 0.09975
    private let DELIVERY_FARE = 5.00
    private let TIP_PERCENTAGE = 0.10

    let primaryColor = Color(hex: "F18D34")
    let greenColor = Color(hex: "388E3C")

    var body: some View {
        VStack(spacing: 0) {
            // Custom Toolbar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(primaryColor)
                Spacer()
                Text("Checkout")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Spacer().frame(width: 60)
            }
            .padding()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach($checkoutItems) { $item in
                        CheckoutItemRow(cartItem: $item, onQuantityChanged: calculateTotal)
                    }
                    .onDelete(perform: deleteItems)
                }
                .padding(.horizontal)
            }

            Divider()

            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    HStack {
                        Text("Delivery Fare")
                        Spacer()
                        Text("$\(DELIVERY_FARE, specifier: "%.2f")")
                    }
                    HStack {
                        Text("Tips (10%)")
                        Spacer()
                        Text("$\(tips, specifier: "%.2f")")
                    }
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

                TextField("Add a note for your order (optional)", text: $orderNote)
                    .padding(10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(primaryColor, lineWidth: 1)
                    )

                HStack(spacing: 12) {
                    ForEach(["Card", "Cash", "Apple Pay"], id: \.self) { method in
                        Button(action: {
                            selectedPaymentMethod = method
                        }) {
                            Text(method)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedPaymentMethod == method ? .white : .black)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedPaymentMethod == method ? primaryColor : Color(.systemGray5))
                                .cornerRadius(8)
                        }
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

                NavigationLink(
                    destination: PaymentView(
                        cartItems: checkoutItems,
                        customer: currentCustomer ?? Customer(id: "", name: "", phone: "", address: ""),
                        restaurant: currentRestaurant ?? Restaurant(id: "", name: "", address: "", imageURL: "", location: nil, operatingHours: [:], rating: 0.0, distanceKm: 0.0, etaMinutes: 0),
                        checkoutTotal: total,
                        orderNote: orderNote,
                        paymentMethod: selectedPaymentMethod
                    ),
                    isActive: $navigateToPayment
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            calculateTotal()
            fetchCustomerData()
            fetchRestaurantData()
        }
    }

    private func calculateTotal() {
        subtotal = checkoutItems.reduce(0) { $0 + ($1.foodPrice * Double($1.quantity)) }
        tips = subtotal * TIP_PERCENTAGE
        gst = subtotal * GST_RATE
        qst = subtotal * QST_RATE
        total = subtotal + tips + DELIVERY_FARE + gst + qst
    }

    private func deleteItems(at offsets: IndexSet) {
        checkoutItems.remove(atOffsets: offsets)
        calculateTotal()
    }

    private func proceedToPayment() {
        print("Proceed to payment with \(checkoutItems.count) items")
        print("Note: \(orderNote)")
        print("Selected payment: \(selectedPaymentMethod)")
        navigateToPayment = true
    }

    private func fetchCustomerData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("customer").child(uid)
        ref.getData { error, snapshot in
            if let val = snapshot?.value as? [String: Any],
               let name = val["name"] as? String,
               let phone = val["phone"] as? String,
               let address = val["address"] as? String {
                currentCustomer = Customer(id: uid, name: name, phone: phone, address: address)
            }
        }
    }

    private func fetchRestaurantData() {
        currentRestaurant = RestaurantHelper.getCurrentRestaurant()
    }
}


struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(checkoutItems: [
            CartItem(
                foodId: "Burger",
                foodDescription: "Juicy Burger",
                foodImage: "https://example.com/burger.jpg",
                restaurantId: "res123",
                foodPrice: 7.99,
                quantity: 2
            ),
            CartItem(
                foodId: "Pizza",
                foodDescription: "Cheesy Pepperoni",
                foodImage: "https://example.com/pizza.jpg",
                restaurantId: "res123",
                foodPrice: 10.99,
                quantity: 1
            )
        ])
    }
}
