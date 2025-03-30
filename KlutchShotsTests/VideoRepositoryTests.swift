import Testing
import Foundation

@MainActor
final class VideoRepositoryTests {

    let repository = VideoRepository(api: VideoAPI.mock)

    @Test func fetchAllVideos() async throws {
        let videos = try await repository.fetchAllVideos()
        #expect(videos.count == 8)
        #expect(repository.videos.count == 8)
    }
}
