//
//  RestaurantHelper.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct RestaurantHelper {
    private static var currentRestaurant: Restaurant?

    // Set globally accessible restaurant
    static func setCurrentRestaurant(_ restaurant: Restaurant) {
        currentRestaurant = restaurant
    }

    // Get globally accessible restaurant
    static func getCurrentRestaurant() -> Restaurant? {
        return currentRestaurant
    }

    // Optionally resolve if one is missing
    static func resolveSelectedRestaurant(_ selectedRestaurant: Restaurant?) -> Restaurant? {
        return selectedRestaurant ?? currentRestaurant
    }

    // Optional check
    static func isRestaurantSet() -> Bool {
        return currentRestaurant != nil
    }
}