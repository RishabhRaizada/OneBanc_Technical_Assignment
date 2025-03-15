import Foundation

struct Item: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let price: String
    let rating: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, rating
        case imageUrl = "image_url"
    }
}
