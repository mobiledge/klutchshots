import Testing
import Foundation
import UIKit
@testable import KlutchShots

struct LiveImageCacheTests {
    // MARK: - Helper Methods
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 50, height: 50)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Tests
    @Test("Cache should initially return nil for non-existent file")
    func testNonExistentFile() async {
        let cache = LiveImageCache()
        let fileName = "nonExistent-\(UUID().uuidString).jpg"
        let fetchedImage = await cache.fetch(fileName: fileName)
        #expect(fetchedImage == nil)
    }

    @Test("Cache should save and retrieve image correctly")
    func testSaveAndRetrieve() async {
        let cache = LiveImageCache()
        let fileName = "testImage-\(UUID().uuidString).jpg"
        let testImage = createTestImage()

        // Save the image
        await cache.save(testImage, fileName: fileName)

        // Retrieve and verify image
        let retrievedImage = await cache.fetch(fileName: fileName)
        #expect(retrievedImage != nil)
    }
}
