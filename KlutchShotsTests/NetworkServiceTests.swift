import Foundation
import XCTest
@testable import KlutchShots

class NetworkServiceTests: XCTestCase {

    var mockSession: MockURLSessionProtocol!
    var imageCache: ImageCache!
    var networkService: NetworkService!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSessionProtocol()
        imageCache = ImageCache()
        networkService = NetworkService(session: mockSession, imageCache: imageCache)
    }

    override func tearDown() {
        mockSession = nil
        networkService = nil
        super.tearDown()
    }

    // MARK: - Videos
    func testFetchVideosSuccess() async throws {
        // Arrange
        mockSession.mockData = try? Videos.mock.toJsonData()
        mockSession.mockResponse = HTTPURLResponse.mock200

        // Act
        let fetched = try await networkService.fetchVideos()

        // Assert
        XCTAssertNil(mockSession.mockError)
        XCTAssertTrue(mockSession.dataFromURLCalled)
        XCTAssertEqual(fetched, Videos.mock)
    }

    func testFetchVideosNetworkError() async {
        // Arrange
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Act & Assert
        do {
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    func testFetchVideosBadStatusCode() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse.mock404

        // Act & Assert
        do {
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }

    func testFetchVideosDecodingError() async {
        // Arrange
        mockSession.mockData = "{\"invalid\": \"json\"}".data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse.mock200

        // Act & Assert
        do {
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - Images
    func testFetchImageSuccessFromNetwork() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/image.jpg")!
        let testImage = UIImage(systemName: "photo")!
        mockSession.mockData = testImage.jpegData(compressionQuality: 1.0)
        mockSession.mockResponse = HTTPURLResponse.mock200

        // Act
        let fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: false)

        // Assert
        XCTAssertNotNil(fetchedImage)
        XCTAssertTrue(mockSession.dataFromURLCalled)
        XCTAssertEqual(mockSession.lastURL, testURL)
        XCTAssertNil(mockSession.mockError)
    }

    func testFetchedImageSavedToCache() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/image.jpg")!
        let testImage = UIImage(systemName: "photo")!
        mockSession.mockData = testImage.jpegData(compressionQuality: 1.0)
        mockSession.mockResponse = HTTPURLResponse.mock200

        // Act
        let _ = try await networkService.fetchImage(from: testURL, checkCache: false)
        let cachedImage = await imageCache.fetch(for: testURL)

        // Assert
        XCTAssertNotNil(cachedImage)
    }

    func testFetchImageSuccessFromCache() async throws {
        let testURL = URL(string: "https://example.com/image.jpg")!
        let testImage = UIImage(systemName: "photo")!

        // Preload the cache with our test image
        await networkService.imageCache.save(testImage, for: testURL)

        // When explicitly bypassing cache, should return nil (since we're not mocking network)
        var fetchedImage = try? await networkService.fetchImage(from: testURL, checkCache: false)
        XCTAssertNil(fetchedImage, "Should return nil when bypassing cache without network response")

        // Verify cache hit. Should return the cached image without network call
        fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: true)
        XCTAssertNotNil(fetchedImage)
    }
}

class MockURLSessionProtocol: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    var dataFromURLCalled = false
    var lastURL: URL?

    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        dataFromURLCalled = true
        lastURL = url

        if let error = mockError {
            throw error
        }

        guard let data = mockData, let response = mockResponse else {
            throw URLError(.unknown)
        }

        return (data, response)
    }
}

extension HTTPURLResponse {
    static var mock200 = HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )

    static var mock404 = HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: 404,
        httpVersion: nil,
        headerFields: nil
    )
}
