import Foundation
import Combine

/// A service that handles file downloads with progress tracking using Combine.
///
/// This implementation uses Apple's Combine framework to provide reactive download progress
/// and completion handling.
final class DownloadService {

    /// Represents the possible results of a download operation using Combine publishers.
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
