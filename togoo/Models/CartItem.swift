import Foundation

struct CartItem: Identifiable, Codable {
    var id: String { cartItemId ?? foodId }

    var cartItemId: String?       // Unique key from Firebase push()
    var foodId: String            // UID of the food item
    var foodDescription: String   // Description of the food item
    var foodImage: String         // URL of the food image
    var foodPrice: Double         // Price of the food item
    var quantity: Int             // Quantity in the cart
    var restaurantId: String      // Restaurant UID

    // MARK: - Initializers

    init(cartItemId: String? = nil, foodId: String, foodDescription: String, foodImage: String, restaurantId: String, foodPrice: Double, quantity: Int) {
        self.cartItemId = cartItemId
        self.foodId = foodId
        self.foodDescription = foodDescription
        self.foodImage = foodImage
        self.restaurantId = restaurantId
        self.foodPrice = foodPrice
        self.quantity = quantity
    }

    init?(dict: [String: Any]) {
        guard let foodId = dict["foodId"] as? String,
              let foodDescription = dict["foodDescription"] as? String,
              let foodImage = dict["foodImage"] as? String,
              let restaurantId = dict["restaurantId"] as? String,
              let foodPriceRaw = dict["foodPrice"],
              let quantity = dict["quantity"] as? Int else {
            return nil
        }

        // Handle price conversion from either String or Double
        if let priceDouble = foodPriceRaw as? Double {
            self.foodPrice = priceDouble
        } else if let priceString = foodPriceRaw as? String, let parsed = Double(priceString) {
            self.foodPrice = parsed
        } else {
            self.foodPrice = 0.0
        }

        self.cartItemId = dict["cartItemId"] as? String
        self.foodId = foodId
        self.foodDescription = foodDescription
        self.foodImage = foodImage
        self.restaurantId = restaurantId
        self.quantity = quantity
    }

    // MARK: - Dictionary for Firebase
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "foodId": foodId,
            "foodDescription": foodDescription,
            "foodImage": foodImage,
            "restaurantId": restaurantId,
            "foodPrice": foodPrice,
            "quantity": quantity
        ]
        if let cartItemId = cartItemId {
            dict["cartItemId"] = cartItemId
        }
        return dict
    }
}
