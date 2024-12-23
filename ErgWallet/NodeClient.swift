import Foundation

class NodeClient {

    static let shared = NodeClient()

    private static let nano: Int64 = 1_000_000_000
    private static let baseURL = "https://ergfi.xyz:9443"

    private init() {}

    func fetchUnspentBoxes(address: String, completion: @escaping (Result<[Box], Error>) -> Void) {
        guard let url = URL(string: "\(NodeClient.baseURL)/blockchain/box/unspent/byAddress?offset=0&limit=100&sortDirection=desc&includeUnconfirmed=false&excludeMempoolSpent=false") else {
            completion(.failure(NSError(domain: "invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = address.data(using: .utf8)

        // TODO remove if https
        request.setValue("*", forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "invalid response", code: 0, userInfo: nil)))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "invalid http status code: \(httpResponse.statusCode))", code: 0, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "no data received", code: 0, userInfo: nil)))
                return
            }
            
            guard let boxes = self.convertBoxes(json: data) else {
                completion(.failure(NSError(domain: "invalid boxes", code: 0, userInfo: nil)))
                return
            }

            completion(.success(boxes))
        }
        task.resume()
    }

    private func convertBoxes(json: Data) -> [Box]? {
        do {
            return try JSONDecoder().decode([Box].self, from: json)
        } catch {
            print("invalid JSON: \(error)")
            return nil
        }
    }

    func sumBoxValues(boxes: [Box]) -> Int64 {
        return boxes.reduce(0) { $0 + $1.value }
    }
    
    func toNano(nano: Int64) -> Double {
        return Double(nano) / Double(NodeClient.nano)
    }
}
