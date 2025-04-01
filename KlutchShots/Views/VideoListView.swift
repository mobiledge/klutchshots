import SwiftUI
import Observation

@MainActor
@Observable
class VideoListViewModel {

    enum LoadingState<T> {
        case loading
        case loaded(T)
        case error(Error)
    }

    var loadingState: LoadingState<[Video]> = .loading
    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func fetchVideos() async {

//        try? await Task.sleep(for: Duration.seconds(5))

        do {
            loadingState = .loading
            let videos = try await networkService.fetchVideos()
            loadingState = .loaded(videos)
        } catch {
            loadingState = .error(error)
        }
    }
}

struct VideoListView: View {

    @State private var viewModel: VideoListViewModel

    internal init(viewModel: VideoListViewModel) {
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
        .navigationTitle("Videos")
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
                AsyncImage(url: URL(string: video.thumbnailUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

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
class LoadedVideoListViewModel: VideoListViewModel {
    override func fetchVideos() async {
        loadingState = .loaded(Videos.mock)
    }
}

#Preview("Loaded State") {
    NavigationStack {
        VideoListView(viewModel: LoadedVideoListViewModel())
    }
}

// MARK: - Loading Preview
class LoadingVideoListViewModel: VideoListViewModel {
    override func fetchVideos() async {
        loadingState = .loading
    }
}

#Preview("Loading state") {
    NavigationStack {
        VideoListView(viewModel: LoadingVideoListViewModel())
    }
}


// MARK: - Error Preview
class ErrorVideoListViewModel: VideoListViewModel {
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

#Preview("Error State") {
    NavigationStack {
        VideoListView(viewModel: ErrorVideoListViewModel())
    }
}


