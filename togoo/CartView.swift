//
//  CartView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CartView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var cartItems: [CartItem] = []
    @State private var navigateToCheckout = false

    let primaryColor = Color(hex: "F18D34")

    private var cartRef: DatabaseReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference(withPath: "cart").child(uid)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔹 Custom Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                    Spacer()
                    Text("Cart")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Spacer().frame(width: 60) // Align title center
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                Divider()

                // 🔹 Cart Items
                if let ref = cartRef {
                    List {
                        ForEach(cartItems) { item in
                            CartItemRowView(
                                cartItem: item,
                                cartRef: ref,
                                onDelete: {
                                    if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                                        cartItems.remove(at: index)
                                    }
                                }
                            )
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }

                // 🔸 Buy Now Button
                Button {
                    if cartItems.isEmpty {
                        print("Cart is empty")
                    } else {
                        navigateToCheckout = true
                    }
                } label: {
                    Text("Buy Now")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "388E3C"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)

                // 🔹 Navigate to CheckoutView
                NavigationLink(destination: CheckoutView(checkoutItems: cartItems), isActive: $navigateToCheckout) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear(perform: loadCartItems)
        }
    }

    private func loadCartItems() {
        guard let ref = cartRef else { return }

        ref.observe(.childAdded) { snapshot, _ in
            if let dict = snapshot.value as? [String: Any],
               let foodId = dict["foodId"] as? String,
               let foodDescription = dict["foodDescription"] as? String,
               let foodImage = dict["foodImage"] as? String,
               let foodPrice = dict["foodPrice"] as? Double,
               let quantity = dict["quantity"] as? Int {
                
                var item = CartItem(
                    foodId: foodId,
                    foodDescription: foodDescription,
                    foodImage: foodImage,
                    restaurantId: dict["restaurantId"] as? String ?? "",
                    foodPrice: foodPrice,
                    quantity: quantity
                )
                item.cartItemId = snapshot.key
                item.restaurantId = dict["restaurantId"] as? String ?? ""
                cartItems.append(item)
            }
        }
    

        ref.observe(.childRemoved) { snapshot in
            if let index = cartItems.firstIndex(where: { $0.cartItemId == snapshot.key }) {
                cartItems.remove(at: index)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        guard let ref = cartRef else { return }
        offsets.forEach { index in
            let item = cartItems[index]
            if let key = item.cartItemId {
                ref.child(key).removeValue { error, _ in
                    if let error = error {
                        print("❌ Failed to delete item: \(error.localizedDescription)")
                    }
                }
            }
        }
        cartItems.remove(atOffsets: offsets)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
