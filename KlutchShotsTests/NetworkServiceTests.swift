import Foundation
import XCTest
@testable import KlutchShots

final class NetworkServiceTests: XCTestCase {
    // MARK: - Properties
    private var networkService: NetworkService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        networkService = nil
        super.tearDown()
    }

    // MARK: - Helper Methods
    private func mockResponse(
        url: URL? = nil,
        statusCode: Int,
        httpVersion: String = "HTTP/1.1"
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url ?? URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: nil
        )!
    }

    // MARK: - Video Tests
    func testFetchVideosSuccess() async throws {
        // Arrange
        let session = NetworkSession { _ in
            (try! Videos.mock.toJsonData(), self.mockResponse(statusCode: 200))
        }
        networkService = NetworkService(session: session)

        // Act
        let fetched = try await networkService.fetchVideos()

        // Assert
        XCTAssertEqual(fetched, Videos.mock)
    }

    func testFetchVideosNetworkError() async {
        // Arrange
        let session = NetworkSession { _ in
            throw URLError(.notConnectedToInternet)
        }
        networkService = NetworkService(session: session)

        do {
            // Act
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            // Assert
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    func testFetchVideosBadStatusCode() async {
        // Arrange
        let session = NetworkSession { _ in
            (try! Videos.mock.toJsonData(), self.mockResponse(statusCode: 500))
        }
        networkService = NetworkService(session: session)

        do {
            // Act
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            // Assert
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }

    func testFetchVideosDecodingError() async {
        // Arrange
        let session = NetworkSession { _ in
            ("{\"invalid\": \"json\"}".data(using: .utf8)!, self.mockResponse(statusCode: 200))
        }
        networkService = NetworkService(session: session)

        do {
            // Act
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            // Assert
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - Image Tests
    func testFetchImageSuccessFromNetwork() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/image.jpg")!
        let session = NetworkSession { url in
            let image = UIImage(systemName: "photo")!
            let data = image.jpegData(compressionQuality: 1.0)!
            return (data, self.mockResponse(url: url, statusCode: 200))
        }

        networkService = NetworkService(session: session)
        await networkService.imageCache.clearCache() // Empty cache to force network fetch

        // Act
        let fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: false)

        // Assert
        XCTAssertNotNil(fetchedImage)
    }

    func testFetchImageSuccessFromCache() async throws {
        // Arrange
        let testURL = URL(string: "https://example.com/image.jpg")!
        let session = NetworkSession { _ in
            (Data(), self.mockResponse(statusCode: 500)) // Network should fail
        }

        networkService = NetworkService(session: session)
        await networkService.imageCache.clearCache()
        await networkService.imageCache.save(
            UIImage(systemName: "photo")!,
            for: testURL
        )

        // Act
        let fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: true)

        // Assert
        XCTAssertNotNil(fetchedImage)
    }
}
