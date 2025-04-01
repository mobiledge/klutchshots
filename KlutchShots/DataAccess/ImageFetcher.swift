import Foundation
import UIKit

actor ImageFetcher {
    private let cache: ImageCache
    private let service: ImageService
    private let placeholder: UIImage

    internal init(cache: any ImageCache, service: any ImageService, placeholder: UIImage) {
        self.cache = cache
        self.service = service
        self.placeholder = placeholder
    }


    func fetchImage(from url: URL, checkCache: Bool = true) async throws -> UIImage {
        let fileName = fileName(for: url)
        if checkCache {
            if let cachedImage = await cache.fetch(fileName: fileName) {
                return cachedImage
            }
        }
        if let image = await service.fetchFromNetwork(url: url) {
            await cache.save(image, fileName: fileName)
            return image
        }
        return placeholder
    }

    private func fileName(for url: URL) -> String {
        let sanitized = url.absoluteString
            .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
        return String(sanitized.prefix(255))
    }
}

protocol ImageService {
    func fetchFromNetwork(url: URL) async -> UIImage?
}

actor LiveImageService: ImageService {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchFromNetwork(url: URL) async -> UIImage? {
        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            return UIImage(data: data)
        } catch {
            print("Error fetching image from network: \(error.localizedDescription)")
            return nil
        }
    }
}

actor MockImageService: ImageService {
    var mockImages = [URL: UIImage]()
    func fetchFromNetwork(url: URL) async -> UIImage? {
        mockImages[url]
    }
}

protocol ImageCache {
    func fetch(fileName: String) async -> UIImage?
    func save(_ image: UIImage, fileName: String) async
}

actor LiveImageCache: ImageCache {
    private let fileManager: FileManager
    private let cacheDirectory: URL

    init() {
        self.fileManager = FileManager.default

        // Get the cache directory in the app's documents folder
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.cacheDirectory = documentsDirectory.appendingPathComponent("ImageCache", isDirectory: true)

        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func fetch(fileName: String) async -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error reading cached image: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ image: UIImage, fileName: String) async {
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard let data = image.pngData() else {
            print("Could not convert image to data")
            return
        }

        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving image to cache: \(error.localizedDescription)")
        }
    }
}

actor MockImageCache: ImageCache {
    var mockImages = [String: UIImage]()
    func fetch(fileName: String) async -> UIImage? {
        mockImages[fileName]
    }
    func save(_ image: UIImage, fileName: String) async {
        mockImages[fileName] = image
    }
}
