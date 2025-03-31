import SwiftUI
import AVKit
import Combine

enum PlayerState: Equatable {
    case loading // Combines both initial loading and buffering
    case playing
    case paused
    case error(String)
}

@Observable
class VideoPlayerViewModel {
    let player: AVPlayer
    var playerState: PlayerState = .loading
    private var cancellables = Set<AnyCancellable>()

    init(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        observePlayerStatus()
        player.play() // Start playing immediately
    }

    private func observePlayerStatus() {
        // Combine both time control and item status observations
        Publishers.CombineLatest(
            player.publisher(for: \.timeControlStatus),
            player.publisher(for: \.currentItem?.status)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] timeStatus, itemStatus in
            guard let self else { return }

            // Handle errors first
            if case .failed = itemStatus,
               let error = player.currentItem?.error {
                playerState = .error(error.localizedDescription)
                return
            }

            // Handle playback states
            switch timeStatus {
            case .paused:
                playerState = .paused
            case .playing:
                playerState = .playing
            case .waitingToPlayAtSpecifiedRate:
                playerState = .loading // Use loading state for buffering too
            @unknown default:
                break
            }
        }
        .store(in: &cancellables)
    }

    func togglePlayPause() {
        playerState == .playing ? player.pause() : player.play()
    }

    var isLoading: Bool {
        playerState == .loading
    }
}

struct VideoPlayerView: View {
    @State private var viewModel: VideoPlayerViewModel

    init(videoURL: URL) {
        _viewModel = State(initialValue: VideoPlayerViewModel(videoURL: videoURL))
    }

    var body: some View {
        VStack {
            ZStack {
                VideoPlayer(player: viewModel.player)
                    .frame(height: 300)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }

            // Controls
            HStack {
                Button(action: viewModel.togglePlayPause) {
                    Image(systemName: viewModel.playerState == .playing ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 50, height: 50)
                }
            }
            .padding()

            // Status indicator
            Text(statusDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var statusDescription: String {
        switch viewModel.playerState {
        case .loading:
            return viewModel.player.currentItem?.status == .readyToPlay ?
                "Buffering..." : "Loading video..."
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .error(let message): return "Error: \(message)"
        }
    }
}

#Preview {
    VideoPlayerView(videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
}
