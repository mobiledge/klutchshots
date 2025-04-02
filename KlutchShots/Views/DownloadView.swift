//
//  DownloadView.swift
//  NetworkService
//
//  Created by Rabin Joshi on 2025-04-01.
//


import Combine
import SwiftUI

@MainActor
@Observable
class DownloadViewModel {

    enum DownloadState {
        case idle
        case downloading(progress: Double)
        case finished(fileURL: URL)
        case failed(error: Error)
    }

    private let video: Video
    private let downloadService = DownloadService()
    private var cancellables = Set<AnyCancellable>()
    var downloadState: DownloadState = .idle
    var isDownloading = false

    init(video: Video) {
        self.video = video
    }

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



struct DownloadView: View {

    @State private var viewModel: DownloadViewModel

    init(viewModel: DownloadViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {

        switch viewModel.downloadState {
        case .idle:
            VStack(spacing: 20) {

                Button("Start Download") {
                    viewModel.downloadFile()
                }
                .buttonStyle(BorderedProminentButtonStyle())

                Text("Ready to download")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .downloading(let progress):
            VStack(spacing: 20) {
                Button("Cancel Download") {
                    viewModel.cancelDownload()
                }
                .buttonStyle(BorderedButtonStyle())
                .tint(.red)

                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)

                Text("Downloading: \(Int(progress * 100))%")
            }
            .padding()

        case .finished(let fileURL):
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 48))
                Text("Download complete")
                Text("File saved at:")
                    .font(.caption)
                Text(fileURL.absoluteString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .failed:
            EmptyView() // Error shown in alert
        }
    }
}

#Preview {
    DownloadView(viewModel: DownloadViewModel(video: Videos.mock.first!))
}


// Helper extensions for error handling
extension DownloadViewModel.DownloadState {
    var isError: Bool {
        if case .failed = self { return true }
        return false
    }

    var error: (any Error)? {
        if case .failed(let error) = self { return error }
        return nil
    }
}
