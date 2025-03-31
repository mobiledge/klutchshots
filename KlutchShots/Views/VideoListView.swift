import SwiftUI
import Observation

@Observable
class VideoListViewModel {
    
    private(set) var videos: [Video] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private let repository: VideoRepository
    internal init(repository: VideoRepository) {
        self.repository = repository
    }

    func fetchVideos() async {
        isLoading = true
        error = nil

        do {
            videos = try await repository.fetchAllVideos()
        } catch {
            self.error = error
            videos = []
        }

        isLoading = false
    }
}

struct VideoListView: View {

    @State private var viewModel: VideoListViewModel

    internal init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: {
                    Task { await viewModel.fetchVideos() }
                })
            } else {
                List(viewModel.videos) { video in
                    VideoRow(video: video)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.fetchVideos()
        }
        .navigationTitle("Videos")
    }
}

// ErrorView remains the same
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

#Preview {
    VideoListView(
        viewModel: VideoListViewModel(
            repository: VideoRepository(
                api: VideoAPI()
            )
        )
    )
}
