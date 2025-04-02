import Combine
import UIKit

protocol URLSessionProtocol {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

actor NetworkService {
    
    static let shared = NetworkService(imageCache: ImageCache())
    
    private let session: URLSessionProtocol
    let imageCache: ImageCache
    
    init(session: URLSessionProtocol = URLSession.shared, imageCache: ImageCache) {
        self.session = session
        self.imageCache = imageCache
    }
    
    func fetchVideos() async throws -> [Video] {
        let urlStr = "https://gist.githubusercontent.com/poudyalanil/ca84582cbeb4fc123a13290a586da925/raw/14a27bd0bcd0cd323b35ad79cf3b493dddf6216b/videos.json"
        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await session.data(from: url, delegate: nil)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            return try Videos(jsonData: data)
            
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
    
    func fetchImage(from url: URL, checkCache: Bool = true) async throws -> UIImage? {
        if checkCache {
            if let cachedImage = await imageCache.fetch(for: url) {
                return cachedImage
            }
        }
        do {
            let (data, response) = try await session.data(from: url, delegate: nil)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            await imageCache.save(image, for: url)
            return image
            
        } catch {
            print("Error fetching image from network: \(error.localizedDescription)")
            throw error
        }
    }
}
