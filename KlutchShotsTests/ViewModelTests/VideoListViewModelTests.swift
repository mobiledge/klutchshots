import XCTest
@testable import KlutchShots

final class VideoListViewModelTests: XCTestCase {

    // MARK: - Test Cases

    @MainActor
    func testInitialStateIsLoading() {
        let service = MockVideoFetcher(result: .success([]))
        let vm = VideoListViewModel(networkService: service)
        XCTAssertEqual(vm.loadingState, .loading)
    }

    @MainActor
    func testFetchVideosSuccess() async {
        // Given
        let expectedVideos = Videos.mock
        let mockNetworkService = MockVideoFetcher(result: .success(expectedVideos))
        let vm = VideoListViewModel(networkService: mockNetworkService)


        // When
        await vm.fetchVideos()

        // Then
        let loadingState = vm.loadingState
        if case .loaded(let videos) = loadingState {
            XCTAssertEqual(videos, expectedVideos)
        } else {
            XCTFail("Expected loaded state with videos, got \(loadingState)")
        }
    }

    @MainActor
    func testFetchVideosFailure() async {
        // Given
        let expectedError = URLError(.badServerResponse)
        let mockNetworkService = MockVideoFetcher(result: .failure(expectedError))
        let vm = VideoListViewModel(networkService: mockNetworkService)

        // When
        await vm.fetchVideos()

        // Then
        let loadingState = vm.loadingState
        if case .error(let error) = loadingState {
            XCTAssertEqual(error as? URLError, expectedError)
        } else {
            XCTFail("Expected error state, got \(loadingState)")
        }
    }

    @MainActor
    func testFetchVideosDoesNotReloadWhenAlreadyLoaded() async {
        // Given
        let expectedVideos = Videos.mock
        let mockNetworkService = MockVideoFetcher(result: .success(expectedVideos))
        let vm = VideoListViewModel(networkService: mockNetworkService)

        // First fetch to get to loaded state
        await vm.fetchVideos()

        // Reset call count
        await mockNetworkService.resetCallCount()

        // When
        await vm.fetchVideos()

        // Then
        let callCount = await mockNetworkService.fetchVideosCallCount
        XCTAssertEqual(callCount, 0, "Should not fetch again when already loaded")
    }
}

// MARK: - Mock VideoFetcher

private actor MockVideoFetcher: VideoFetching {
    let result: Result<[Video], Error>
    var fetchVideosCallCount = 0

    init(result: Result<[Video], Error>) {
        self.result = result
    }

    func fetchVideos() async throws -> [Video] {
        fetchVideosCallCount += 1
        return try result.get()
    }

    func resetCallCount() async {
        fetchVideosCallCount = 0
    }
}
