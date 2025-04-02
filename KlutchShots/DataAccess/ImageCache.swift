import Foundation
import UIKit

actor ImageCache {
    private let fileManager: FileManager
    private let cacheDirectory: URL

    init() {
        self.fileManager = FileManager.default

        // Get the cache directory in the app's documents folder
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)

        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
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

    func sanitizedFileName(for url: URL) -> String {
        let sanitized = url.absoluteString
            .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
        return String(sanitized.prefix(255))
    }
}
