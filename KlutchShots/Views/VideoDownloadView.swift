import SwiftUI

struct DownloadView: View {
    let videoUrl: URL
    let isLive: Bool

    @State private var downloadTask: URLSessionDownloadTask?
    @State private var downloadProgress: Double = 0
    @State private var isDownloading = false
    @State private var showDownloadError = false
    @State private var errorMessage = ""

    var body: some View {
        if !isLive {
            VStack {
                Divider()

                Button(action: {
                    if isDownloading {
                        cancelDownload()
                    } else {
                        startDownload()
                    }
                }) {
                    HStack {
                        Image(systemName: isDownloading ? "xmark.circle" : "arrow.down.circle")
                        Text(isDownloading ? "Cancel Download" : "Download Video")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                if isDownloading {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .padding(.top, 4)

                    Text("\(Int(downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .alert("Download Error", isPresented: $showDownloadError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func startDownload() {

        isDownloading = true
        downloadProgress = 0

        let session = URLSession(
            configuration: .default,
            delegate: DownloadDelegate(progress: { progress in
                DispatchQueue.main.async {
                    self.downloadProgress = progress
                }
            }, completion: { error in
                DispatchQueue.main.async {
                    self.isDownloading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showDownloadError = true
                    }
                }
            }),
            delegateQueue: nil
        )

        downloadTask = session.downloadTask(with: videoUrl)
        downloadTask?.resume()
    }

    private func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        downloadProgress = 0
    }
}

// Keep the DownloadDelegate class the same as before
class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Double) -> Void
    private let completionHandler: (Error?) -> Void

    init(progress: @escaping (Double) -> Void, completion: @escaping (Error?) -> Void) {
        self.progressHandler = progress
        self.completionHandler = completion
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completionHandler(nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler(error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
}

#Preview {
    DownloadView(videoUrl: Video.mockArray().first!.videoUrl, isLive: false)
}
