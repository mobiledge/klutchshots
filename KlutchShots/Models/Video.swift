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
extension Videos {

    /// JSON encoding & decoding
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()

    init(jsonData: Data) throws {
        self = try Self.decoder.decode(Videos.self, from: jsonData)
    }

    func toJsonData() throws -> Data {
        try Self.encoder.encode(self)
    }


    /// Mock data
    static var mock: Videos {
        do {
            return try Videos(jsonData: bundleContents("videos.json"))
        } catch {
            print("ERROR: Failed to create mock Videos: \(error)")
            return Videos()
        }
    }

    private static func bundleContents(_ resource: String) -> Data {
        guard let url = Bundle.main.url(forResource: resource, withExtension: nil) else {
            print("ERROR: Could not find resource '\(resource)' in bundle")
            return Data()
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("ERROR: Failed to load data from \(url.path): \(error)")
            return Data()
        }
    }
}
