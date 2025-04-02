import Foundation
import XCTest
@testable import KlutchShots

class NetworkServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func mockResponse(url: URL? = nil, statusCode: Int) -> HTTPURLResponse {
            HTTPURLResponse(
                url: url ?? URL(string: "https://api.example.com")!,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
        }

    // MARK: - Videos
    func testFetchVideosSuccess() async throws {

        let session = NetworkSession { _ in
            return (try! Videos.mock.toJsonData(), self.mockResponse(statusCode: 200))
        }
        let networkService = NetworkService(session: session)
        let fetched = try await networkService.fetchVideos()

        // Assert
        XCTAssertEqual(fetched, Videos.mock)
    }

    func testFetchVideosNetworkError() async {

        let session = NetworkSession { _ in
            throw URLError(.notConnectedToInternet)
        }
        let networkService = NetworkService(session: session)

        do {
            _ = try await networkService.fetchVideos()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    func testFetchVideosBadStatusCode() async {

        let session = NetworkSession { _ in
            return (try! Videos.mock.toJsonData(), self.mockResponse(statusCode: 500))
        }
        let networkService = NetworkService(session: session)

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

        let session = NetworkSession { _ in
            return ("{\"invalid\": \"json\"}".data(using: .utf8)!, self.mockResponse(statusCode: 200))
        }
        let networkService = NetworkService(session: session)

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
        let testURL = URL(string: "https://example.com/image.jpg")!
        let session = NetworkSession { url in
            let image = UIImage(systemName: "photo")!
            let data = image.jpegData(compressionQuality: 1.0)!
            return (data, self.mockResponse(url: url, statusCode: 200))
        }
        let networkService = NetworkService(session: session)
        await networkService.imageCache.clearCache() // empty cache forcing fetch from network

        let fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: false)
        XCTAssertNotNil(fetchedImage)
    }

    func testFetchImageSuccessFromCache() async throws {

        let testURL = URL(string: "https://example.com/image.jpg")!
        let session = NetworkSession { url in
            // Setting up network to fail
            return (Data(), self.mockResponse(statusCode: 500))
        }

        let networkService = NetworkService(session: session)
        await networkService.imageCache.clearCache()
        await networkService.imageCache.save(
            UIImage(systemName: "photo")!,
            for: testURL
        )

        let fetchedImage = try await networkService.fetchImage(from: testURL, checkCache: true)
        XCTAssertNotNil(fetchedImage)
    }
}
