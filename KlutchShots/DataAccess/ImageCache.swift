import UIKit

//actor ImageCache {
//    static let shared = ImageCache()
//
//    private var memoryCache = NSCache<NSString, UIImage>()
//    private let cacheDirectory: URL
//
//    init() {
//        memoryCache.name = "ImageCache"
//        memoryCache.countLimit = 100
//
//        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
//        cacheDirectory = folderURLs[0].appendingPathComponent("ImageCache")
//
//        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
//    }
//
//    func fetch(url: URL) -> UIImage? {
//        let fileName = fileName(for: url)
//        if let memoryImage = memoryCache.object(forKey: fileName as NSString) {
//            return memoryImage
//        }
//        if let diskImage = loadFromDisk(fileName: fileName) {
//            memoryCache.setObject(diskImage, forKey: fileName as NSString)
//            return diskImage
//        }
//        return nil
//    }
//
//    func save(image: UIImage, url: URL) {
//        let fileName = fileName(for: url)
//        memoryCache.setObject(image, forKey: fileName as NSString)
//        saveToDisk(image: image, fileName: fileName)
//    }
//
//    func clearCache() {
//        memoryCache.removeAllObjects()
//        try? FileManager.default.removeItem(at: cacheDirectory)
//        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
//    }
//
//    private func loadFromDisk(fileName: String) -> UIImage? {
//        let fileURL = cacheDirectory.appendingPathComponent(fileName)
//        guard let data = try? Data(contentsOf: fileURL) else { return nil }
//        return UIImage(data: data)
//    }
//
//    private func saveToDisk(image: UIImage, fileName: String) {
//        guard let data = image.jpegData(compressionQuality: 1.0) else {
//            print("Error: Failed to create JPEG data from image")
//            return
//        }
//        let filePath = cacheDirectory.appendingPathComponent(fileName)
//        do {
//            try data.write(to: filePath)
//            print("Image saved successfully at: \(filePath.path)")
//        } catch {
//            print("Error saving image: \(error.localizedDescription)")
//        }
//    }
//
//    private func fileName(for url: URL) -> String {
//        let sanitized = url.absoluteString
//            .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
//        return String(sanitized.prefix(255))
//    }
//}
