import Foundation
import Combine

/// Handles file downloads using Combine.
/// Provide reactive download progress and completion handling.
final class VideoDownloader {

    /// Represents the possible results of a download operation
    enum DownloadResult {
        case fractionCompleted(Double)
        case completed(URL)
    }

    // MARK: - Properties

    private var task: URLSessionDownloadTask?
    private var observation: NSKeyValueObservation?

    // MARK: - Public Methods
    func downloadWithProgress(from url: URL) -> AnyPublisher<DownloadResult, Error> {
        let subject = PassthroughSubject<DownloadResult, Error>()
        cancelCurrentDownload()

        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            defer {
                self?.cancelCurrentDownload()
            }

            if let error = error {
                subject.send(completion: .failure(error))
                return
            }

            guard let tempURL = tempURL else {
                subject.send(completion: .failure(URLError(.badServerResponse)))
                return
            }

            subject.send(.completed(tempURL))
            subject.send(completion: .finished)
        }

        self.task = task

        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            subject.send(.fractionCompleted(progress.fractionCompleted))
        }

        task.resume()

        return subject
            .handleEvents(
                receiveCancel: { [weak self] in
                    self?.cancelCurrentDownload()
                }
            )
            .eraseToAnyPublisher()
    }

    func cancelCurrentDownload() {
        task?.cancel()
        observation?.invalidate()
        task = nil
        observation = nil
    }

    // MARK: - Deinitialization

    deinit {
        cancelCurrentDownload()
    }
}
