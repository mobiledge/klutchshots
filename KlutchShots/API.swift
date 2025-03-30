import Foundation

struct RequestDispatcher {
    var dispatch: (URLRequest) async throws -> (Data, URLResponse)

    static let live = RequestDispatcher { request in
        try await URLSession.shared.data(for: request)
    }

    // MARK: - Mock Helpers

    static func mock200(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 200,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock201(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 201,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock400(
        responseData: Data = Data(),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 400,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock404(
        responseData: Data = Data("Not Found".utf8),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 404,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    static func mock500(
        responseData: Data = Data("Server Error".utf8),
        url: URL = URL(string: "https://api.example.com")!,
        delay: Duration = .milliseconds(500)
    ) -> RequestDispatcher {
        mockResponse(
            statusCode: 500,
            responseData: responseData,
            url: url,
            delay: delay
        )
    }

    // Generic mock creator
    private static func mockResponse(
        statusCode: Int,
        responseData: Data,
        url: URL,
        delay: Duration
    ) -> RequestDispatcher {
        RequestDispatcher { _ in
            try await Task.sleep(for: delay)
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (responseData, response)
        }
    }
}

class API {
    static var shared: API = {
        let url = URL(string: "https://gist.githubusercontent.com/poudyalanil/ca84582cbeb4fc123a13290a586da925/raw/14a27bd0bcd0cd323b35ad79cf3b493dddf6216b")!
        return API(baseURL: url, dispatcher: .live)
    }()

    let baseURL: URL
    let dispatcher: RequestDispatcher

    init(baseURL: URL, dispatcher: RequestDispatcher = .live) {
        self.baseURL = baseURL
        self.dispatcher = dispatcher
    }

    func get(path: String) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await dispatcher.dispatch(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}

extension API {
    func fetchAllVideos() async throws -> [Video] {
        let path = "videos.json"
        let data = try await get(path: path)
        do {
            return try JSONDecoder().decode([Video].self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// Error types for API requests
enum APIError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}
