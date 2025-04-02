//
//  VideoDetailView.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import SwiftUI

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

    init(video: Video) {
        self.video = video
    }
}

// Extension for preview purposes
extension VideoDetailViewModel {
    static func mock() -> VideoDetailViewModel {
        return VideoDetailViewModel(video: Videos.mock[0])
    }
}

struct VideoDetailView: View {
    @State var viewModel: VideoDetailViewModel

    init(viewModel: VideoDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VideoPlayerView(videoURL: viewModel.videoUrl)

                // Video info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 4) {
                        Text(viewModel.author)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("· \(viewModel.views)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

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

                    Divider()

                    Text(viewModel.description)
                        .font(.body)
                        .padding(.vertical, 10)

                    Divider()

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
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        VideoDetailView(viewModel: VideoDetailViewModel.mock())
    }
}
