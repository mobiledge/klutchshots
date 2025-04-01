import Testing // Import the new framework
import Foundation
import UIKit // For UIImage

struct ImageServiceTests {

    // Test case: Successful image fetch
    @Test func fetchImageSuccess() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/image.png")!
        let mockSession = createMockURLSession()
        let service = LiveImageService(urlSession: mockSession)
        let imageData = createTestImageData()
        let mockResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)

        MockURLProtocol.removeAllMocks() // Clear previous mocks
        MockURLProtocol.registerMock(url: testURL, data: imageData, response: mockResponse, error: nil)

        // Act
        let image = await service.fetchFromNetwork(url: testURL)

        // Assert
        #expect(image != nil, "Image should not be nil on success")
        #expect(image?.size == CGSize(width: 1, height: 1), "Image size should match the test data")

        // Clean up (optional, as removeAllMocks is called at the start)
         MockURLProtocol.removeAllMocks()
    }

    // Test case: Failure due to non-2xx status code (e.g., 404)
    @Test func fetchImageFailureStatusCode() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/notfound.jpg")!
        let mockSession = createMockURLSession()
        let service = LiveImageService(urlSession: mockSession)
        let mockResponse = HTTPURLResponse(url: testURL, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil) // 404 Not Found

        MockURLProtocol.removeAllMocks()
        MockURLProtocol.registerMock(url: testURL, data: nil, response: mockResponse, error: nil) // No data needed for 404

        // Act
        let image = await service.fetchFromNetwork(url: testURL)

        // Assert
        #expect(image == nil, "Image should be nil when status code is not 2xx")

        // Clean up
         MockURLProtocol.removeAllMocks()
    }

     // Test case: Failure due to invalid image data
    @Test func fetchImageFailureInvalidData() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/invalid.data")!
        let mockSession = createMockURLSession()
        let service = LiveImageService(urlSession: mockSession)
        let invalidData = "this is not image data".data(using: .utf8) // Data that cannot form a UIImage
        let mockResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)

        MockURLProtocol.removeAllMocks()
        MockURLProtocol.registerMock(url: testURL, data: invalidData, response: mockResponse, error: nil)

        // Act
        let image = await service.fetchFromNetwork(url: testURL)

        // Assert
        #expect(image == nil, "Image should be nil when data is invalid")

        // Clean up
         MockURLProtocol.removeAllMocks()
    }

    // Test case: Failure due to network error during fetch
    @Test func fetchImageFailureNetworkError() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/networkerror")!
        let mockSession = createMockURLSession()
        let service = LiveImageService(urlSession: mockSession)
        let mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil) // Example network error

        MockURLProtocol.removeAllMocks()
        MockURLProtocol.registerMock(url: testURL, data: nil, response: nil, error: mockError) // Register the error

        // Act
        let image = await service.fetchFromNetwork(url: testURL)

        // Assert
        #expect(image == nil, "Image should be nil when a network error occurs")

        // Clean up
         MockURLProtocol.removeAllMocks()
    }
}

class MockURLProtocol: URLProtocol {

    // Dictionary to hold our mock responses (data, response, error) keyed by URL
    static var mockResponses = [URL: (data: Data?, response: URLResponse?, error: Error?)]()

    // Caches the request for later use in startLoading
    private var cachedRequest: URLRequest?

    // Required overrides for URLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept all requests whose URLs are in our mock dictionary
        return request.url != nil && mockResponses[request.url!] != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Required, just return the original request
        return request
    }

    override func startLoading() {
        guard let request = request.url, let mock = MockURLProtocol.mockResponses[request] else {
            // Should not happen if canInit returned true, but good practice
            let error = NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock found for \(request.url?.absoluteString ?? "unknown URL")"])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        // Respond with an error if one is registered
        if let error = mock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            // Respond with data and response if they are registered
            if let response = mock.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = mock.data {
                client?.urlProtocol(self, didLoad: data)
            }
        }

        // Signal completion
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Required, nothing to do for simple mocks
    }

    // --- Helper methods for tests ---
    static func registerMock(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        mockResponses[url] = (data, response, error)
    }

    static func removeAllMocks() {
        mockResponses.removeAll()
    }
}

// --- Helper to create test image data ---
// Using a tiny, valid Base64 encoded GIF image.
func createTestImageData() -> Data? {
    let base64String = "R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=" // 1x1 blue pixel GIF
    return Data(base64Encoded: base64String)
}

// --- Helper to create a mock URLSession ---
func createMockURLSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral // Use ephemeral to avoid disk caching
    config.protocolClasses = [MockURLProtocol.self] // Register our mock protocol
    return URLSession(configuration: config)
}

class MockURLSession: URLSession {
    // Customizable data and response to return from the mock
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    // Track whether data(from:) was called
    var dataFromURLCalled = false
    var lastURL: URL?

    // Override the data(from:) method that our NetworkService uses
    override func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        dataFromURLCalled = true
        lastURL = url

        // If an error is set, throw it
        if let error = mockError {
            throw error
        }

        // Return the mock data and response or throw if not set
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.unknown)
        }

        return (data, response)
    }
}
