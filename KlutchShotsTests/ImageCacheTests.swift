import Testing
import UIKit

struct ImageCacheTests {

    private func makeTestImage(color: UIColor = .red) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func areImagesEqual(_ image1: UIImage?, _ image2: UIImage?) -> Bool {
        if image1 == nil && image2 == nil { return true }
        guard let img1 = image1, let img2 = image2 else { return false }
        return img1.pngData() == img2.pngData()
    }

    @Test("Fetch returns nil when cache is empty")
    func testFetchEmpty() async throws {
        await ImageCache.shared.clearCache()
        let testURL = URL(string: "https://example.com/nonexistent.jpg")!
        #expect(await ImageCache.shared.fetch(url: testURL) == nil)
    }

    @Test("Save and fetch returns the same image")
    func testSaveFetch() async throws {
        await ImageCache.shared.clearCache()
        let testURL = URL(string: "https://example.com/image1.jpg")!
        let originalImage = makeTestImage(color: .blue)

        await ImageCache.shared.save(image: originalImage, url: testURL)
        #expect(areImagesEqual(originalImage, await ImageCache.shared.fetch(url: testURL)))
    }

    @Test("Fetch retrieves image from memory cache")
    func testMemoryFetch() async throws {
        await ImageCache.shared.clearCache()
        let testURL = URL(string: "https://example.com/memory_test.png")!
        let originalImage = makeTestImage(color: .green)

        await ImageCache.shared.save(image: originalImage, url: testURL)
        #expect(areImagesEqual(originalImage, await ImageCache.shared.fetch(url: testURL)))
    }

    @Test("Clear cache removes all stored images")
    func testClearCache() async throws {
        await ImageCache.shared.clearCache()
        let testURL = URL(string: "https://example.com/image_to_clear.gif")!
        let originalImage = makeTestImage(color: .yellow)

        await ImageCache.shared.save(image: originalImage, url: testURL)
        let beforeClear = await ImageCache.shared.fetch(url: testURL)
        await ImageCache.shared.clearCache()
        let afterClear = await ImageCache.shared.fetch(url: testURL)

        #expect(areImagesEqual(originalImage, beforeClear))
        #expect(afterClear == nil)
    }

    @Test("Save overwrites existing image with new one")
    func testSaveOverwrite() async throws {
        await ImageCache.shared.clearCache()
        let testURL = URL(string: "https://example.com/overwrite.jpg")!
        let firstImage = makeTestImage(color: .purple)
        let secondImage = makeTestImage(color: .orange)

        await ImageCache.shared.save(image: firstImage, url: testURL)
        let firstFetch = await ImageCache.shared.fetch(url: testURL)
        await ImageCache.shared.save(image: secondImage, url: testURL)
        let secondFetch = await ImageCache.shared.fetch(url: testURL)

        #expect(areImagesEqual(firstImage, firstFetch))
        #expect(areImagesEqual(secondImage, secondFetch))
        #expect(!areImagesEqual(firstImage, secondFetch))
    }
}
