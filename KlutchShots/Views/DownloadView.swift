import Combine
import SwiftUI

// MARK: - ViewModel

@MainActor
@Observable
final class DownloadViewModel {

    // MARK: - State

    enum DownloadState {
        case idle
        case downloading(progress: Double)
        case finished(fileURL: URL)
        case failed(error: Error)
    }

    // MARK: - Properties

    private let video: Video
    private let downloadService = DownloadService()
    private var cancellables = Set<AnyCancellable>()

    var downloadState: DownloadState = .idle
    var isDownloading = false

    // MARK: - Initialization

    init(video: Video) {
        self.video = video
    }

    // MARK: - Public Methods

    func downloadFile() {
        isDownloading = true
        downloadState = .downloading(progress: 0)

        downloadService.downloadWithProgress(from: video.videoUrl)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isDownloading = false
                    if case .failure(let error) = completion {
                        self?.downloadState = .failed(error: error)
                    }
                },
                receiveValue: { [weak self] result in
                    switch result {
                    case .fractionCompleted(let progress):
                        self?.downloadState = .downloading(progress: progress)
                    case .completed(let url):
                        self?.downloadState = .finished(fileURL: url)
                    }
                }
            )
            .store(in: &cancellables)
    }

    func cancelDownload() {
        downloadService.cancelCurrentDownload()
        isDownloading = false
        downloadState = .idle
    }
}

// MARK: - View

struct DownloadView: View {
    @State private var viewModel: DownloadViewModel

    // MARK: - Initialization

    init(viewModel: DownloadViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.downloadState {
            case .idle:
                idleView

            case .downloading(let progress):
                downloadingView(progress: progress)

            case .finished(let fileURL):
                finishedView(fileURL: fileURL)

            case .failed(let error):
                failedView(error: error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Subviews

    private var idleView: some View {
        VStack(spacing: 20) {
            Button("Start Download") {
                viewModel.downloadFile()
            }
            .buttonStyle(.borderedProminent)

            Text("Ready to download")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func downloadingView(progress: Double) -> some View {
        VStack(spacing: 20) {
            Button("Cancel Download") {
                viewModel.cancelDownload()
            }
            .buttonStyle(.bordered)
            .tint(.red)

            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.linear)
                .frame(height: 8)

            Text("Downloading: \(Int(progress * 100))%")
        }
    }

    private func finishedView(fileURL: URL) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 48))

            Text("Download complete")
                .font(.headline)

            VStack {
                Text("File saved at:")
                    .font(.caption)
                Text(fileURL.absoluteString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func failedView(error: Error) -> some View {
        VStack(spacing: 20) {
            Button("Restart Download") {
                viewModel.downloadFile()
            }
            .buttonStyle(.borderedProminent)

            Text(error.localizedDescription.capitalized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    DownloadView(viewModel: DownloadViewModel(video: Videos.mock.first!))
}
