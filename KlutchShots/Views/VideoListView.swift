import SwiftUI
import Observation

// MARK: - Loading State

/// Represents the different states of an asynchronous loading operation
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

// MARK: - View Model

@MainActor
@Observable
class VideoListViewModel {

    // MARK: - Properties

    var loadingState: LoadingState<[Video]> = .loading
    private let networkService: VideoFetching

    init(networkService: VideoFetching = NetworkService.shared) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    func fetchVideos() async {
        // Skip if already loaded
        if case .loaded = loadingState {
            return
        }

        loadingState = .loading

        do {
            let videos = try await networkService.fetchVideos()
            loadingState = .loaded(videos)
        } catch {
            loadingState = .error(error)
        }
    }
}

// MARK: - Preview Subclasses

extension VideoListViewModel {
    /// Mock subclass for previewing loading state
    final class LoadingPreview: VideoListViewModel {
        override func fetchVideos() async {
            loadingState = .loading
        }
    }

    /// Mock subclass for previewing loaded state with mock data
    final class LoadedPreview: VideoListViewModel {
        override func fetchVideos() async {
            loadingState = .loaded(Videos.mock)
        }
    }

    /// Mock subclass for previewing error state
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

// MARK: - Main View

struct VideoListView: View {
    @State private var viewModel: VideoListViewModel

    init(viewModel: VideoListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
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
                    Task { await viewModel.fetchVideos() }
                }
            }
        }
        .task {
            await viewModel.fetchVideos()
        }
        .navigationTitle("KlutchShots")
    }
}

// MARK: - Content Views

struct VideoListContentView: View {
    private var videos: [Video]
    @State private var selectedVideo: Video?

    init(videos: [Video]) {
        self.videos = videos
    }

    var body: some View {
        List(videos) { video in
            NavigationLink {
                VideoDetailView(viewModel: VideoDetailViewModel(video: video))
            } label: {
                VideoRow(video: video)
            }
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
                    viewModel: ThumbnailImageViewModel(
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

// MARK: - Badge Views

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

// MARK: - Previews

#Preview("Loaded State") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.LoadedPreview())
    }
}

#Preview("Loading State") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.LoadingPreview())
    }
}

#Preview("Error State") {
    NavigationStack {
        VideoListView(viewModel: VideoListViewModel.ErrorPreview())
    }
}
