import Foundation
import UIKit

/// `ImageCache` is an actor-based caching system for storing and retrieving images.
/// It uses the app's cache directory to persist images based on their URLs.
/// This helps reduce redundant network requests and improves performance.
///
/// In the future, an in-memory cache (e.g., `NSCache`) could be added
/// to further optimize performance and reduce disk access.
actor ImageCache {
    static let shared = ImageCache()
    private let fileManager: FileManager
    private let cacheDirectory: URL

    init() {
        self.fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create cache directory: \(error.localizedDescription)")
        }
    }

    func fetch(for url: URL) async -> UIImage? {
        let fileName = sanitizedFileName(for: url)
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


    func save(_ image: UIImage, for url: URL) async {
        let fileName = sanitizedFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 1.0) else {
            print("Could not convert image to data")
            return
        }

        do {
            try data.write(to: fileURL)
            print("Saved to \(fileURL.absoluteString)")
        } catch {
            print("Error saving image to cache: \(error.localizedDescription)")
        }
    }

    func clearCache() async {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("Cache cleared successfully")
        } catch {
            print("Error clearing cache: \(error.localizedDescription)")
        }
    }

    /// Generates a sanitized filename from a URL to ensure valid file storage.
    /// Replaces non-alphanumeric characters with underscores, which may cause filename collisions.
    /// A better approach could be to use a hashing function (e.g., SHA256) for uniqueness.
    func sanitizedFileName(for url: URL) -> String {
        let sanitized = url.absoluteString
            .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
        return String(sanitized.prefix(255))
    }
}
