import Foundation

struct FoodCategory: Identifiable, Codable {
    var id: String { name }

    let name: String
    var imageName: String? = nil      // for local assets like "pizza"
    var imageUrl: String? = nil       // for remote URLs

    var hasImageUrl: Bool {
        guard let imageUrl = imageUrl else { return false }
        return !imageUrl.isEmpty
    }

    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }

    init(name: String, imageUrl: String) {
        self.name = name
        self.imageUrl = imageUrl
    }
}
