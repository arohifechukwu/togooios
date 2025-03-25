//
//  FoodItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import Foundation

struct FoodItem: Codable, Identifiable {
    let id: String       // UID (e.g., "Apple Pie")
    let description: String // Description of the food item
    let imageUrl: String
    let price: Double

    // MARK: - Initializers

    init(id: String, description: String, imageUrl: String, price: Double) {
        self.id = id
        self.description = description
        self.imageUrl = imageUrl
        self.price = price
    }

    // Optionally, if you need to initialize from a dictionary (for example, from Firebase)
    init?(from dictionary: [String: Any], id: String) {
        guard let description = dictionary["description"] as? String,
              let imageUrl = dictionary["imageURL"] as? String,
              let price = dictionary["price"] as? Double
        else {
            return nil
        }
        self.id = id
        self.description = description
        self.imageUrl = imageUrl
        self.price = price
    }
}

