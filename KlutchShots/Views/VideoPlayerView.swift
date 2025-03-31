import SwiftUI
import AVKit
import Combine

enum PlayerState: Equatable {
    case loading
    case ready
    case error(String)
}

@MainActor
@Observable
final class VideoPlayerViewModel {
    let player: AVPlayer
    var playerState: PlayerState = .loading
    private var cancellables = Set<AnyCancellable>()

    init(videoURL: URL) {
        self.player = AVPlayer(url: videoURL)
        setupObservers()
//        player.play()
    }

    private func setupObservers() {
        // Handle player item status changes
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

        // Handle playback failures
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                    self?.playerState = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }

    func cleanup() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        player.replaceCurrentItem(with: nil)
    }
}

struct VideoPlayerView: View {
    @State private var viewModel: VideoPlayerViewModel

    init(videoURL: URL) {
        _viewModel = State(wrappedValue: VideoPlayerViewModel(videoURL: videoURL))
    }

    var body: some View {
        ZStack {
            Color.black
                .aspectRatio(16/9, contentMode: .fit)

            VideoPlayer(player: viewModel.player)
                .aspectRatio(16/9, contentMode: .fit)
                .onAppear {
                    //viewModel.player.play()
                }
                .onDisappear {
                    viewModel.cleanup()
                }

            if case .loading = viewModel.playerState {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }

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
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VideoPlayerView(videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
}
