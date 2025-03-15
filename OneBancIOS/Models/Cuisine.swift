import Foundation

struct Cuisine: Codable {
    let cuisineId: String
    let cuisineName: String
    let cuisineImageUrl: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageUrl = "cuisine_image_url"
        case items
    }
}
