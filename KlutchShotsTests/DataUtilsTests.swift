import XCTest
@testable import KlutchShots

// MARK: - Test Models

private struct User: Codable, Equatable, JSONConvertible {
    let id: Int
    let name: String
}

private struct AppConfig: Codable, Equatable, JSONConvertible, BundleLoadable {
    let apiUrl: String
    let timeout: Int
}

// MARK: - Test Cases

final class DataUtilsTests: XCTestCase {

    // MARK: - JSONConvertible Tests

    func testEncodeDecode() throws {
        // Given
        let originalUser = User(id: 1, name: "Test User")

        // When
        let jsonData = try originalUser.toJsonData()
        let decodedUser = try User(jsonData: jsonData)

        // Then
        XCTAssertEqual(originalUser, decodedUser)
    }

    func testDecodeFromInvalidDataThrows() {
        // Given
        let invalidData = Data("invalid json".utf8)

        // Then
        XCTAssertThrowsError(try User(jsonData: invalidData))
    }

    // MARK: - BundleLoadable Tests

    func testLoadFromBundle() throws {
        // When
        let testBundle = Bundle(for: DataUtilsTests.self)
        let config = try AppConfig(bundleResource: "test_config.json", bundle: testBundle)

        // Then
        XCTAssertEqual(config.apiUrl, "https://api.example.com")
        XCTAssertEqual(config.timeout, 30)
    }

    func testLoadFromBundleWithMissingFileThrows() {
        // When
        let testBundle = Bundle(for: DataUtilsTests.self)

        // Then
        XCTAssertThrowsError(try AppConfig(bundleResource: "nonexistent_file.json", bundle: testBundle)) { error in
            XCTAssertEqual((error as NSError).domain, "BundleLoadable")
            XCTAssertEqual((error as NSError).code, 404)
        }
    }
}
