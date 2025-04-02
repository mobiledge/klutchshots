import Foundation
import Combine

class DownloadService {
    enum DownloadResult {
        case fractionCompleted(Double)
        case completed(URL)
    }

    private var task: URLSessionDownloadTask?
    private var observation: NSKeyValueObservation?

    func downloadWithProgress(from url: URL) -> AnyPublisher<DownloadResult, Error> {
        let subject = PassthroughSubject<DownloadResult, Error>()

        // Clean up any existing task and observation
        task?.cancel()
        observation?.invalidate()

        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            defer {
                self?.task = nil
                self?.observation?.invalidate()
                self?.observation = nil
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
                    self?.task?.cancel()
                    self?.observation?.invalidate()
                    self?.task = nil
                    self?.observation = nil
                }
            )
            .eraseToAnyPublisher()
    }

    deinit {
        cancelCurrentDownload()
    }

    func cancelCurrentDownload() {
        task?.cancel()
        observation?.invalidate()
        task = nil
        observation = nil
    }
}
