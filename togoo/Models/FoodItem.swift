import Foundation

struct FoodItem: Identifiable, Codable {
    var id: String                  // UID
    var description: String
    var imageURL: String
    var price: Double
    var restaurantId: String
    var parentNode: String?        // e.g., "menu", "Top Picks"
    var category: String?          // e.g., "Pizza", "Burgers" (nil for non-menu items)

    // MARK: - Initializer
    init(id: String, description: String, imageURL: String, restaurantId: String, price: Double, parentNode: String? = nil, category: String? = nil) {
        self.id = id
        self.description = description
        self.imageURL = imageURL
        self.restaurantId = restaurantId
        self.price = price
        self.parentNode = parentNode
        self.category = category
    }

    // MARK: - Firebase-style initializer
    init?(from dictionary: [String: Any], id: String, restaurantId: String) {
        guard let description = dictionary["description"] as? String,
              let imageURL = dictionary["imageURL"] as? String,
              let priceRaw = dictionary["price"] else {
            return nil
        }

        let price: Double
        if let priceDouble = priceRaw as? Double {
            price = priceDouble
        } else if let priceString = priceRaw as? String, let parsedPrice = Double(priceString) {
            price = parsedPrice
        } else {
            print("Invalid price format: \(priceRaw)")
            price = 0.0
        }

        self.id = id
        self.description = description
        self.imageURL = imageURL
        self.restaurantId = restaurantId
        self.price = price
        self.parentNode = dictionary["parentNode"] as? String
        self.category = dictionary["category"] as? String
    }
}
