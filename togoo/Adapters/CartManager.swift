//
//  CartManager.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import Foundation
import FirebaseDatabase
import FirebaseAuth

struct CartManager {

    // Load all cart items for the current user
    static func loadCartItems(completion: @escaping ([CartItem]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in")
            completion([])
            return
        }

        let ref = Database.database().reference(withPath: "cart").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            var items: [CartItem] = []
            for case let child as DataSnapshot in snapshot.children {
                if let dict = child.value as? [String: Any],
                   var item = CartItem(dict: dict) {
                    item.cartItemId = child.key
                    items.append(item)
                }
            }
            completion(items)
        }
    }

    // Add a food item to cart
    static func addItem(_ food: FoodItem) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in")
            return
        }

        let ref = Database.database().reference(withPath: "cart/\(uid)").childByAutoId()
        let cartItem = CartItem(
            foodId: food.id,
            foodDescription: food.description,
            foodImage: food.imageURL,
            restaurantId: food.restaurantId,
            foodPrice: food.price,
            quantity: 1
        )

        ref.setValue(cartItem.toDictionary()) { error, _ in
            if let error = error {
                print("❌ Failed to add item to cart: \(error.localizedDescription)")
            } else {
                print("✅ Added \(food.id) to cart")
            }
        }
    }

    // Delete an item from cart
    static func deleteItem(withKey key: String, completion: ((Bool) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in")
            completion?(false)
            return
        }

        let ref = Database.database().reference(withPath: "cart/\(uid)/\(key)")
        ref.removeValue { error, _ in
            if let error = error {
                print("❌ Failed to delete item: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("✅ Item removed successfully")
                completion?(true)
            }
        }
    }

    // Observe cart changes (child added/removed)
    static func observeCartChanges(onAdd: @escaping (CartItem) -> Void, onRemove: @escaping (String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference(withPath: "cart/\(uid)")

        ref.observe(.childAdded) { snapshot in
            if let dict = snapshot.value as? [String: Any],
               var item = CartItem(dict: dict) {
                item.cartItemId = snapshot.key
                onAdd(item)
            }
        }

        ref.observe(.childRemoved) { snapshot in
            onRemove(snapshot.key)
        }
    }
}
