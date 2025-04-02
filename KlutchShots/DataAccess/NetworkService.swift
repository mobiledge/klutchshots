import Combine
import UIKit


// MARK: - NetworkSession

struct NetworkSession {
    var dispatch: (URL) async throws -> (Data, URLResponse)
    static var live = NetworkSession { url in
        try await URLSession.shared.data(from: url)
    }
}

/// A network service actor that handles API requests and image caching
class NetworkService {

    // MARK: - Shared Instance
    static let shared = NetworkService()

    // MARK: - Properties
    let session: NetworkSession
    let imageCache: ImageCache

    // MARK: - Initialization
    init(
        session: NetworkSession = .live,
        imageCache: ImageCache = .shared
    ) {
        self.session = session
        self.imageCache = imageCache
    }

    func validateHTTPResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse) // Not an HTTP response
        }
        switch httpResponse.statusCode {
        case 200...299:
            return // Success - no error
        case 400:
            throw URLError(.badURL) // Bad Request
        case 401:
            throw URLError(.userAuthenticationRequired) // Unauthorized
        case 403:
            throw URLError(.noPermissionsToReadFile) // Forbidden
        case 404:
            throw URLError(.fileDoesNotExist) // Not Found
        case 408:
            throw URLError(.timedOut) // Request Timeout
        case 429:
            throw URLError(.dataNotAllowed) // Too Many Requests (rate limiting)
        case 500...599:
            throw URLError(.badServerResponse) // Server Error
        default:
            throw URLError(.unknown) // Unhandled status code
        }
    }
}


// MARK: - VideoFetching

protocol VideoFetching {
    func fetchVideos() async throws -> [Video]
}

extension NetworkService: VideoFetching {
    func fetchVideos() async throws -> [Video] {
        let url = Constants.baseURL.appending(path: "videos.json")
        do {
            let (data, response) = try await session.dispatch(url)
            try validateHTTPResponse(response)
            return try Videos(jsonData: data)
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
}

protocol ImageFetching {
    func fetchImage(from url: URL, checkCache: Bool) async throws -> UIImage?
}

extension NetworkService: ImageFetching {

    func fetchImage(from url: URL, checkCache: Bool = true) async throws -> UIImage? {
        // Check cache first if enabled
        if checkCache, let cachedImage = await imageCache.fetch(for: url) {
            return cachedImage
        }

        do {
            let (data, response) = try await session.dispatch(url)
            try validateHTTPResponse(response)
            guard let image = UIImage(data: data) else {
                return nil
            }

            // Cache the downloaded image
            await imageCache.save(image, for: url)
            return image
        } catch {
            print("Error fetching image from network: \(error.localizedDescription)")
            throw error
        }
    }
}
