import SwiftUI

// MARK: - ViewModel

class VideoDetailViewModel: ObservableObject {
    // MARK: - Input Properties
    let video: Video

    // MARK: - Output Properties
    var title: String { video.title }
    var author: String { video.author }
    var views: String { "\(video.views) views" }
    var isLive: Bool { video.isLive }
    var duration: String { video.duration }
    var description: String { video.description ?? "-" }
    var videoUrl: URL { video.videoUrl }

    // MARK: - Initialization
    init(video: Video) {
        self.video = video
    }
}

// MARK: - Preview Extension
extension VideoDetailViewModel {
    static func mock() -> VideoDetailViewModel {
        VideoDetailViewModel(video: Videos.mock[0])
    }
}

// MARK: - View

struct VideoDetailView: View {
    @State private var viewModel: VideoDetailViewModel

    // MARK: - Initialization
    init(viewModel: VideoDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        content
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                videoPlayer
                videoInfo
            }
        }
    }

    private var videoPlayer: some View {
        VideoPlayerView(videoURL: viewModel.videoUrl)
    }

    private var videoInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
            authorAndViewsView
            liveOrDurationView
            descriptionView
            downloadSection
        }
        .padding(.horizontal, 16)
    }

    private var titleView: some View {
        Text(viewModel.title)
            .font(.title)
            .fontWeight(.bold)
    }

    private var authorAndViewsView: some View {
        HStack(spacing: 4) {
            Text(viewModel.author)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("· \(viewModel.views)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var liveOrDurationView: some View {
        if viewModel.isLive {
            HStack {
                LiveBadge()
                Text("Streaming now")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } else {
            Text("Duration: \(viewModel.duration)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var descriptionView: some View {
        VStack {
            Divider()
            Text(viewModel.description)
                .font(.body)
                .padding(.vertical, 10)
            Divider()
        }
    }

    private var downloadSection: some View {
        HStack {
            Spacer()
            DownloadView(
                viewModel: DownloadViewModel(
                    video: viewModel.video
                )
            )
            .padding()
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        VideoDetailView(viewModel: VideoDetailViewModel.mock())
    }
}
