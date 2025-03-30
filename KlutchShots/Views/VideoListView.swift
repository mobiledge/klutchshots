import SwiftUI

struct VideoListView: View {
    let videos: [Video]

    var body: some View {
        List(videos) { video in
            VideoRow(video: video)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
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
            HStack(alignment: .top, spacing: 12) {
                // Channel icon (placeholder)
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)

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
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
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
    VideoListView(videos: Video.mockArray())
}
