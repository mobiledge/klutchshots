import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer

    init(url: URL) {
        self.videoURL = url
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .aspectRatio(16/9, contentMode: .fit)
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }

            HStack {
                Button(action: {
                    player.seek(to: .zero)
                    player.play()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                }
                .padding()

                Button(action: {
                    if player.timeControlStatus == .playing {
                        player.pause()
                    } else {
                        player.play()
                    }
                }) {
                    Image(systemName: player.timeControlStatus == .playing ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                .padding()
            }
        }
    }
}

#Preview {
    VideoPlayerView(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
}
