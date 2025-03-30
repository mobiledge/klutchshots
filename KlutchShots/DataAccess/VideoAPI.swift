import Foundation

private let BASEURL = URL(string: "https://gist.githubusercontent.com/poudyalanil/ca84582cbeb4fc123a13290a586da925/raw/14a27bd0bcd0cd323b35ad79cf3b493dddf6216b")!

class VideoAPI {

    static let live = VideoAPI()
    static let mock = MockVideoAPI()

    func fetchAllVideos() async throws -> [Video] {
        let url = BASEURL.appendingPathComponent("videos.json")
        let data = try await get(url: url)
        return try Video.decodeArray(from: data)
    }

    private func get(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        return data
    }
}

class MockVideoAPI: VideoAPI {
    override func fetchAllVideos() async throws -> [Video] {
        let delay = Duration.milliseconds(500)
        try await Task.sleep(for: delay)
        let videos = Video.mockArray()
        return videos
    }
}


// Error types for API requests
enum APIError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}
