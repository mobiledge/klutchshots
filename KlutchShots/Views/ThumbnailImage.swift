//
//  AsyncCachedImage.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-04-01.
//

import SwiftUI

@MainActor
@Observable
class AsyncCachedImageViewModel {

    let url: URL
    var loadingState = LoadingState<UIImage>.loading

    init(url: URL) {
        self.url = url
    }

    func reloadData() async {
        do {
            if case .loaded(_) = loadingState {
                return
            }
            if let image = try await NetworkService.shared.fetchImage(from: url, checkCache: true) {
                loadingState = .loaded(image)
            }
        } catch {
            loadingState = .error(error)
        }
    }
}

struct ThumbnailImage: View {
    @State private var viewModel: AsyncCachedImageViewModel

    init(viewModel: AsyncCachedImageViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            default:
                ZStack {
                    Color(uiColor: UIColor.systemGray6)

                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(uiColor: UIColor.systemGray3))
                        .frame(maxWidth: 120)
                }
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .animation(.easeInOut(duration: 0.3), value: viewModel.loadingState)
        .task {
            await viewModel.reloadData()
        }
    }
}

#Preview {
    ThumbnailImage(viewModel: AsyncCachedImageViewModel(url: URL(string: "https://img.jakpost.net/c/2019/09/03/2019_09_03_78912_1567484272._large.jpg")!))
}

#Preview {
    ThumbnailImage(viewModel: AsyncCachedImageViewModel(url: URL(string: "https://example.com")!))
}

