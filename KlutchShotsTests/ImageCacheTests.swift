import XCTest
@testable import KlutchShots

final class ImageCacheTests: XCTestCase {

    var cache: ImageCache!
    var testImage: UIImage!
    let testURL = URL(string: "https://example.com/image.png")!

    override func setUp() async throws {
        cache = ImageCache()
        testImage = createTestImage()
    }

    override func tearDown() async throws {
        let fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        try? fileManager.removeItem(at: cacheDirectory)
    }

    func testSaveAndFetchImage() async throws {
        await cache.save(testImage, for: testURL)
        let fetchedImage = await cache.fetch(for: testURL)
        XCTAssertNotNil(fetchedImage)
    }

    func testFetchNonExistentImage() async throws {
        let nonExistentURL = URL(string: "https://example.com/nonexistent.png")!
        let fetchedImage = await cache.fetch(for: nonExistentURL)
        XCTAssertNil(fetchedImage)
    }

    func testSanitizedFileName() async throws {
        let url = URL(string: "https://example.com/image?param=value&other=123")!
        let sanitizedName = await cache.sanitizedFileName(for: url)
        XCTAssertEqual(sanitizedName, "https___example_com_image_param_value_other_123")
    }

    // MARK: - Helper Methods
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 50, height: 50)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
