import AVKit
import Combine
import SwiftUI

enum PlayerState: Equatable {
    case loading
    case ready
    case error(String)
}

@MainActor
@Observable
final class VideoPlayerViewModel {
    // MARK: - Properties

    let player: AVPlayer
    var playerState: PlayerState = .loading

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(videoURL: URL) {
        self.player = AVPlayer(url: videoURL)
        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        observePlayerItemStatus()
        observePlaybackFailures()
    }

    private func observePlayerItemStatus() {
        player.publisher(for: \.currentItem?.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }

                switch status {
                case .readyToPlay:
                    playerState = .ready
                case .failed:
                    if let error = player.currentItem?.error {
                        playerState = .error(error.localizedDescription)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func observePlaybackFailures() {
        NotificationCenter.default
            .publisher(for: .AVPlayerItemFailedToPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                    self?.playerState = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Cleanup

    func cleanup() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        player.replaceCurrentItem(with: nil)
    }
}

struct VideoPlayerView: View {
    // MARK: - Properties

    @State private var viewModel: VideoPlayerViewModel

    // MARK: - Initialization

    init(videoURL: URL) {
        _viewModel = State(wrappedValue: VideoPlayerViewModel(videoURL: videoURL))
    }

    // MARK: - Views

    var body: some View {
        ZStack {
            playerBackground
            videoPlayer
            loadingView
            errorView
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            viewModel.player.play()
        }
    }

    private var playerBackground: some View {
        Color.black
            .aspectRatio(16/9, contentMode: .fit)
    }

    private var videoPlayer: some View {
        VideoPlayer(player: viewModel.player)
            .aspectRatio(16/9, contentMode: .fit)
            .onDisappear {
                viewModel.cleanup()
            }
    }

    @ViewBuilder
    private var loadingView: some View {
        if case .loading = viewModel.playerState {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if case .error(let message) = viewModel.playerState {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                Text(message)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
        }
    }
}

// MARK: - Previews

#Preview {
    VideoPlayerView(
        videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    )
}
