//
//  CartItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import Foundation

struct CartItem: Identifiable, Codable {
    var id: String { cartItemId ?? foodId } // ✅ required by Identifiable

    var cartItemId: String?      // Unique key from Firebase push() (optional)
    var foodId: String           // UID for the food item
    var foodDescription: String  // Description of the food item
    var foodImage: String        // URL string for the food image
    var foodPrice: Double        // Price of the food item
    var quantity: Int            // Quantity of the food item in the cart

    // Default initializer
    init(cartItemId: String? = nil, foodId: String, foodDescription: String, foodImage: String, foodPrice: Double, quantity: Int) {
        self.cartItemId = cartItemId
        self.foodId = foodId
        self.foodDescription = foodDescription
        self.foodImage = foodImage
        self.foodPrice = foodPrice
        self.quantity = quantity
    }

    // Initialize from a dictionary (useful when fetching data from Firebase)
    init?(dict: [String: Any]) {
        guard let foodId = dict["foodId"] as? String,
              let foodDescription = dict["foodDescription"] as? String,
              let foodImage = dict["foodImage"] as? String,
              let foodPrice = dict["foodPrice"] as? Double,
              let quantity = dict["quantity"] as? Int else {
            return nil
        }
        self.foodId = foodId
        self.foodDescription = foodDescription
        self.foodImage = foodImage
        self.foodPrice = foodPrice
        self.quantity = quantity
        self.cartItemId = dict["cartItemId"] as? String
    }

    // Convert the CartItem into a dictionary (useful for saving to Firebase)
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "foodId": foodId,
            "foodDescription": foodDescription,
            "foodImage": foodImage,
            "foodPrice": foodPrice,
            "quantity": quantity
        ]
        if let cartItemId = cartItemId {
            dict["cartItemId"] = cartItemId
        }
        return dict
    }
}
