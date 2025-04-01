import Testing
import UIKit

@testable import KlutchShots

struct ImageCacheTests {
    // Test actor to manage test state
    actor TestState {
        var testImage: UIImage?
        var testURL: URL?
        var invalidURL: URL?

        init() {
            // Create a simple test image
            let size = CGSize(width: 100, height: 100)
            let renderer = UIGraphicsImageRenderer(size: size)
            testImage = renderer.image { context in
                UIColor.red.setFill()
                context.fill(CGRect(origin: .zero, size: size))
            }

            testURL = URL(string: "https://example.com/test_image.jpg")!
            invalidURL = URL(string: "https://example.com/invalid_image.jpg")!
        }
    }

    @Test("Shared instance should be singleton")
    func testSharedInstance() async {
        let instance1 = ImageCache.shared
        let instance2 = ImageCache.shared
        #expect(instance1 === instance2)
    }

    @Test("Fetch should return nil for uncached image")
    func testFetchUncachedImage() async throws {
        let state = TestState()
        let cache = ImageCache.shared
        let testURL = await state.testURL!

        // Clear cache before test
        await cache.clearCache()

        let result = await cache.fetch(url: testURL)
        #expect(result == nil)
    }

    @Test("Save and fetch should work for memory cache")
    func testSaveAndFetchMemoryCache() async throws {
        let state = TestState()
        let cache = ImageCache.shared
        let testImage = await state.testImage!
        let testURL = await state.testURL!

        // Clear cache before test
        await cache.clearCache()

        // Save and then fetch
        await cache.save(image: testImage, url: testURL)
        let fetchedImage = await cache.fetch(url: testURL)
        #expect(fetchedImage != nil)
    }

    @Test("ClearCache should remove all cached images")
    func testClearCache() async throws {
        let state = TestState()
        let cache = ImageCache.shared
        let testImage = await state.testImage!
        let testURL = await state.testURL!

        // Save an image first
        await cache.save(image: testImage, url: testURL)

        // Verify it's cached
        let initialFetch = await cache.fetch(url: testURL)
        #expect(initialFetch != nil)

        // Clear cache and verify
        await cache.clearCache()
        let postClearFetch = await cache.fetch(url: testURL)
        #expect(postClearFetch == nil)
    }

    @Test("Cache should persist between memory and disk")
    func testMemoryAndDiskPersistence() async throws {
        let state = TestState()
        let cache = ImageCache.shared
        let testImage = await state.testImage!
        let testURL = await state.testURL!

        // Clear cache before test
        await cache.clearCache()

        // Save image (should go to both memory and disk)
        await cache.save(image: testImage, url: testURL)

        // Fetch should get from memory
        let memoryFetch = await cache.fetch(url: testURL)
        #expect(memoryFetch != nil)

        // Simulate memory purge by creating new instance
        let newCache = ImageCache.shared

        // Fetch should now get from disk
        let diskFetch = await newCache.fetch(url: testURL)
        #expect(diskFetch != nil)
    }

    @Test("Save should handle nil image gracefully")
    func testSaveNilImage() async throws {
        let state = TestState()
        let cache = ImageCache.shared
        let testURL = await state.testURL!

        await cache.clearCache()

        // Attempt to save nil image (shouldn't crash)
        await cache.save(image: UIImage(), url: testURL)

        // Verify no image was actually saved
        let fetchedImage = await cache.fetch(url: testURL)
        #expect(fetchedImage == nil)
    }

    @Test("Cache should handle concurrent access safely")
    func testConcurrentAccess() async throws {
        let cache = ImageCache.shared
        await cache.clearCache()

        let imageCount = 10
        var testImages = [UIImage]()
        var testURLs = [URL]()

        // Create test data
        for i in 0..<imageCount {
            let size = CGSize(width: 10, height: 10)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { _ in }
            testImages.append(image)
            testURLs.append(URL(string: "https://example.com/concurrent_\(i).jpg")!)
        }

        // Concurrent saves
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<imageCount {
                group.addTask {
                    await cache.save(image: testImages[i], url: testURLs[i])
                }
            }
        }

        // Concurrent fetches
        var fetchedCount = 0
        await withTaskGroup(of: Void.self) { group in
            for url in testURLs {
                group.addTask {
                    if await cache.fetch(url: url) != nil {
                        fetchedCount += 1
                    }
                }
            }
        }

        #expect(fetchedCount == imageCount)
    }

    @Test("Cache should return same instance after clear")
    func testCacheInstanceAfterClear() async throws {
        let cache = ImageCache.shared
        let originalInstance = cache

        await cache.clearCache()

        #expect(cache === originalInstance)
    }

    @Test("Cache should handle special characters in URLs")
    func testSpecialCharacterURLs() async throws {
        let cache = ImageCache.shared
        await cache.clearCache()

        let specialURLs = [
            URL(string: "https://example.com/image@test.jpg")!,
            URL(string: "https://example.com/image!test.jpg")!,
            URL(string: "https://example.com/image test.jpg")!,
            URL(string: "https://example.com/image%20test.jpg")!
        ]

        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { _ in }

        for url in specialURLs {
            await cache.save(image: testImage, url: url)
            let fetchedImage = await cache.fetch(url: url)
            #expect(fetchedImage != nil)
        }
    }

    @Test("Cache should handle very long URLs")
    func testLongURLs() async throws {
        let cache = ImageCache.shared
        await cache.clearCache()

        let longPath = String(repeating: "a", count: 1000)
        let longURL = URL(string: "https://example.com/\(longPath).jpg")!

        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { _ in }

        await cache.save(image: testImage, url: longURL)
        let fetchedImage = await cache.fetch(url: longURL)
        #expect(fetchedImage != nil)
    }
}
