import Foundation

class ApiManager {
    static let shared = ApiManager()
    private let baseUrl = "https://uat.onebanc.ai/emulator/interview/"

    private init() {}

    // ✅ Fetch All Items
    func fetchItemList(completion: @escaping (Result<[Cuisine], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)get_item_list") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("uonebancservceemultrS3cg8RaL30", forHTTPHeaderField: "X-Partner-API-Key")
        request.setValue("get_item_list", forHTTPHeaderField: "X-Forward-Proxy-Action")
        
        let body = ["page": 1, "count": 10]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(CompleteResponseWrapper.self, from: data)
                    completion(.success(result.cuisines))
                } catch {
                    print("Decoding Error: \(error)")
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // ✅ Fetch Filtered Items
    func fetchFilteredItems(
        cuisineType: String?,
        priceRange: String?,
        minRating: String?,
        completion: @escaping (Result<[Item], Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseUrl)get_item_by_filter") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("uonebancservceemultrS3cg8RaL30", forHTTPHeaderField: "X-Partner-API-Key")
        request.setValue("get_item_by_filter", forHTTPHeaderField: "X-Forward-Proxy-Action")
        
        var body: [String: Any] = [:]
        if let cuisineType = cuisineType {
            body["cuisine_type"] = cuisineType
        }
        if let priceRange = priceRange {
            body["price_range"] = priceRange
        }
        if let minRating = minRating {
            body["min_rating"] = minRating
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(CompleteResponseWrapper.self, from: data)
                    let items = result.cuisines.flatMap { $0.items }
                    completion(.success(items))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // ✅ Place Order
    func placeOrder(items: [Item], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)place_order") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("uonebancservceemultrS3cg8RaL30", forHTTPHeaderField: "X-Partner-API-Key")
        request.setValue("place_order", forHTTPHeaderField: "X-Forward-Proxy-Action")
        
        let body = [
            "items": items.map { ["id": $0.id] }
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Order Response: \(response)")
                    completion(.success("Order placed successfully"))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

// ✅ Full Response Wrapper
struct CompleteResponseWrapper: Codable {
    let cuisines: [Cuisine]
}
