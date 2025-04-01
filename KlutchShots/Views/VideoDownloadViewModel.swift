import SwiftUI

@MainActor
@Observable
class VideoDownloadViewModel {
    let videoUrl: URL
    var downloadProgress: Double = 0
    var isDownloading = false
    var showDownloadError = false
    var errorMessage = ""
    var downloadedFileURL: URL?

    private var downloadTask: URLSessionDownloadTask?

    init(videoUrl: URL) {
        self.videoUrl = videoUrl
    }

    func startDownload() {
        isDownloading = true
        downloadProgress = 0
        downloadedFileURL = nil

        let session = URLSession(
            configuration: .default,
            delegate: DownloadDelegate(
                progress: { [weak self] progress in
                    DispatchQueue.main.async {
                        self?.downloadProgress = progress
                    }
                },
                completion: { [weak self] (fileURL, error) in
                    DispatchQueue.main.async {
                        self?.isDownloading = false
                        if let error = error {
                            self?.errorMessage = error.localizedDescription
                            self?.showDownloadError = true
                        } else if let fileURL = fileURL {
                            self?.downloadedFileURL = fileURL
                            print("File saved to: \(fileURL.path)")
                        }
                    }
                }
            ),
            delegateQueue: nil
        )

        downloadTask = session.downloadTask(with: videoUrl)
        downloadTask?.resume()
    }

    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        downloadProgress = 0
    }
}

struct VideoDownloadView: View {
    let isLive: Bool
    @State private var viewModel: VideoDownloadViewModel

    init(videoUrl: URL, isLive: Bool) {
        self.isLive = isLive
        self._viewModel = State(wrappedValue: VideoDownloadViewModel(videoUrl: videoUrl))
    }

    var body: some View {
        if !isLive {
            VStack {
                Divider()

                Button(action: {
                    if viewModel.isDownloading {
                        viewModel.cancelDownload()
                    } else {
                        viewModel.startDownload()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isDownloading ? "xmark.circle" : "arrow.down.circle")
                        Text(viewModel.isDownloading ? "Cancel Download" : "Download Video")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                if viewModel.isDownloading {
                    ProgressView(value: viewModel.downloadProgress, total: 1.0)
                        .padding(.top, 4)

                    Text("\(Int(viewModel.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .alert("Download Error", isPresented: $viewModel.showDownloadError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Double) -> Void
    private let completionHandler: (URL?, Error?) -> Void

    init(progress: @escaping (Double) -> Void, completion: @escaping (URL?, Error?) -> Void) {
        self.progressHandler = progress
        self.completionHandler = completion
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: false)
            let savedURL = documentsURL.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "video.mp4")

            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: savedURL.path) {
                try FileManager.default.removeItem(at: savedURL)
            }

            // Move the downloaded file
            try FileManager.default.moveItem(at: location, to: savedURL)
            completionHandler(savedURL, nil)
        } catch {
            completionHandler(nil, error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler(nil, error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
}

#Preview {
    VideoDownloadView(videoUrl: Videos.mock.first!.videoUrl, isLive: false)
}
