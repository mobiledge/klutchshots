import XCTest
import Combine
@testable import KlutchShots

final class DownloadServiceTests: XCTestCase {
    var downloadService: DownloadService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        downloadService = DownloadService()
    }

    override func tearDown() {
        downloadService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testDownloadProgress() {
        let expectation = XCTestExpectation(description: "Should receive progress updates")
        let testURL = URL(string: "https://example.com/file.zip")!

        var receivedProgress: [Double] = []

        downloadService.downloadWithProgress(from: testURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                if case let .fractionCompleted(progress) = result {
                    receivedProgress.append(progress)
                    if progress == 1.0 {
                        expectation.fulfill()
                    }
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertFalse(receivedProgress.isEmpty)
    }

    func testDownloadCompletion() {
        let expectation = XCTestExpectation(description: "Should complete download")
        let testURL = URL(string: "https://example.com/file.zip")!


        var receivedCompletion = false

        downloadService.downloadWithProgress(from: testURL)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { result in
                if case .completed = result {
                    receivedCompletion = true
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(receivedCompletion)
    }

    func testDownloadCancellation() {
        let expectation = XCTestExpectation(description: "Should cancel download")
        let testURL = URL(string: "https://example.com/file.zip")!

        let publisher = downloadService.downloadWithProgress(from: testURL)

        var receivedCancel = false

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    receivedCancel = true
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        downloadService.cancelCurrentDownload()

        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(receivedCancel)
    }
}
