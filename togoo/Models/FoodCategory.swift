//
//  FoodCategory.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//



import Foundation

struct FoodCategory: Identifiable, Codable {
    var id: String { name } // Makes it usable in ForEach

    let name: String
    var imageResId: Int? = nil   // Optional for compatibility
    var imageUrl: String? = nil
    var imageName: String? = nil // Used for local asset images

    var imageAsset: String? {
        return imageName
    }

    var hasImageUrl: Bool {
        guard let imageUrl = imageUrl else { return false }
        return !imageUrl.isEmpty
    }

    // Initializers
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }

    init(name: String, imageUrl: String) {
        self.name = name
        self.imageUrl = imageUrl
    }
}
