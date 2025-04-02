import SwiftUI
import Observation

enum LoadingState<T> {
    case loading
    case loaded(T)
    case error(Error)
}

extension LoadingState: Equatable where T: Equatable {
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        case let (.error(lhsError), .error(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
@Observable
class VideoListViewModel {

    var loadingState: LoadingState<[Video]> = .loading
    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func fetchVideos() async {
        do {
            if case .loaded(_) = loadingState {
                return
            }
            loadingState = .loading
            let videos = try await networkService.fetchVideos()
            loadingState = .loaded(videos)
        } catch {
            loadingState = .error(error)
        }
    }

    /**
     Mock subclasses used for SwiftUI previews and testing.
     These subclasses override `fetchVideos()` to provide predefined states
     without making actual network requests. This allows the UI to be previewed
     in different loading conditions:
     - `LoadingPreview`: Simulates a loading state.
     - `LoadedPreview`: Simulates a successful fetch with mock video data.
     - `ErrorPreview`: Simulates an error state with a predefined error message.
     */

    final class LoadingPreview: VideoListViewModel {
        override func fetchVideos() async {
            loadingState = .loading
        }
    }

    final class LoadedPreview: VideoListViewModel {
        override func fetchVideos() async {
            loadingState = .loaded(Videos.mock)
        }
    }

    final class ErrorPreview: VideoListViewModel {
        override func fetchVideos() async {
            loadingState = .error(
                NSError(
                    domain: "com.example.error",
                    code: 9999,
                    userInfo: [NSLocalizedDescriptionKey: "Something went wrong."]
                )
            )
        }
    }
}


struct VideoListView: View {

    @State private var viewModel: VideoListViewModel

    init(viewModel: VideoListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {

        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView()

            case .loaded(let videos):
                VideoListContentView(videos: videos)

            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchVideos()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchVideos()
        }
        .navigationTitle("KlutchShots")
    }
}

struct VideoListContentView: View {

    private var videos: [Video]
    @State private var selectedVideo: Video?

    internal init(videos: [Video]) {
        self.videos = videos
    }

    var body: some View {
        List(videos) { video in
            NavigationLink(destination: {
                VideoDetailView(video: video)
            }, label: {
                VideoRow(video: video)
            })
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -20))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}


struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Text("An error occurred: \(error.localizedDescription)")
                .foregroundColor(.red)
                .padding()

            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

struct VideoRow: View {
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {

                                ThumbnailImage(
                    viewModel: AsyncCachedImageViewModel(
                        url: video.thumbnailUrl
                    )
                )

                if video.isLive {
                    LiveBadge()
                        .padding(8)
                } else {
                    DurationBadge(duration: video.duration)
                        .padding(8)
                }
            }

            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text(video.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("· \(video.views) views")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
}


//struct VideoRow: View {
//    let video: Video
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            ZStack(alignment: .bottomTrailing) {
//                AsyncImage(url: URL(string: video.thumbnailUrl)) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(maxWidth: .infinity, minHeight: 200)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(16/9, contentMode: .fit)
//                    case .failure:
//                        Image(systemName: "photo")
//                            .resizable()
//                            .aspectRatio(16/9, contentMode: .fit)
//                            .foregroundColor(.gray)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//
//                if video.isLive {
//                    LiveBadge()
//                        .padding(8)
//                } else {
//                    DurationBadge(duration: video.duration)
//                        .padding(8)
//                }
//            }
//
//            // Video info
//            VStack(alignment: .leading, spacing: 4) {
//                Text(video.title)
//                    .font(.headline)
//                    .lineLimit(2)
//
//                HStack(spacing: 4) {
//                    Text(video.author)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//
//                    Text("· \(video.views) views")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//            .padding(.horizontal, 16)
//        }
//        .padding(.bottom, 16)
//    }
//}

struct DurationBadge: View {
    let duration: String

    var body: some View {
        Text(duration)
            .font(.caption)
            .bold()
            .foregroundColor(.white)
            .padding(4)
            .background(Color.black.opacity(0.7))
            .cornerRadius(4)
    }
}

struct LiveBadge: View {
    var body: some View {
        Text("LIVE")
            .font(.caption)
            .bold()
            .foregroundColor(.white)
            .padding(4)
            .background(Color.red.opacity(0.9))
            .cornerRadius(4)
    }
}

// MARK: - Loaded Preview
#Preview("Loaded State") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.LoadedPreview())
    }
}

#Preview("Loading state") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.LoadingPreview())
    }
}

#Preview("Error State") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.ErrorPreview())
    }
}


