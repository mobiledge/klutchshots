import Foundation
import UIKit


// MARK: - ImageFetcher
actor ImageFetcher {
    static let shared = ImageFetcher()
    private let cache: ImageCache
    private let session: URLSession

    init(cache: ImageCache = .shared, session: URLSession = .shared) {
        self.cache = cache
        self.session = session
    }

    func fetchImage(from url: URL, checkCache: Bool = true) async throws -> UIImage {
        // Check cache first if requested
        if checkCache {
            if let cachedImage = await cache.fetch(url: url) {
                return cachedImage
            }
        }

        // Fetch from network if not in cache or cache check skipped
        let image = try await fetchFromNetwork(url: url)

        // Save to cache for future use
        await cache.save(image: image, url: url)

        return image
    }

    // MARK: - Private
    func fetchFromNetwork(url: URL) async throws -> UIImage {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        return image
    }
}

// MARK: - ImageCache

