import Foundation

struct Video: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnailUrl: URL
    let duration: String
    let uploadTime: String
    let views: String
    let author: String
    let videoUrl: URL
    let description: String
    let subscriber: String
    let isLive: Bool
}

typealias Videos = [Video]
extension Videos: JSONConvertible, BundleLoadable {

    /// Mock data
    static var mock: Videos {
        do {
            return try Videos(bundleResource: "videos.json")
        } catch {
            print("ERROR: Failed to create mock Videos: \(error)")
            return Videos()
        }
    }
}
