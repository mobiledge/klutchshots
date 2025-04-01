//
//  VideoDetailView.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import SwiftUI

struct VideoDetailView: View {
    let video: Video

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VideoPlayerView(videoURL: video.videoUrl)

                // Video info
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 4) {
                        Text(video.author)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("· \(video.views) views")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if video.isLive {
                        HStack {
                            LiveBadge()
                            Text("Streaming now")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Duration: \(video.duration)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text(video.description ?? "-")
                        .font(.body)

                    VideoDownloadView(videoUrl: video.videoUrl, isLive: false)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    VideoDetailView(video: Videos.mock.first!)
}
