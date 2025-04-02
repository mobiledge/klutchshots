import SwiftUI

// MARK: - ViewModel

@MainActor
@Observable
final class ThumbnailImageViewModel {
    // MARK: - Properties

    let url: URL
    var loadingState = LoadingState<UIImage>.loading

    // MARK: - Initialization

    init(url: URL) {
        self.url = url
    }

    // MARK: - Public Methods

    func reloadData() async {
        // Skip reloading if we already have a loaded image
        if case .loaded = loadingState {
            return
        }

        do {
            let image = try await NetworkService.shared.fetchImage(from: url, checkCache: true)
            if let image {
                loadingState = .loaded(image)
            }
        } catch {
            loadingState = .error(error)
        }
    }
}

// MARK: - View

struct ThumbnailImage: View {
    // MARK: - Properties

    @State private var viewModel: ThumbnailImageViewModel

    // MARK: - Initialization

    init(viewModel: ThumbnailImageViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loaded(let image):
                loadedImage(image)
            case .loading:
                loadingView
            case .error:
                loadingView // Show same view for error state for now
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .animation(.easeInOut(duration: 0.3), value: viewModel.loadingState)
        .task {
            await viewModel.reloadData()
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func loadedImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
    }

    private var loadingView: some View {
        ZStack {
            Color(uiColor: .systemGray6)

            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(uiColor: .systemGray3))
                .frame(maxWidth: 120)
        }
    }
}

// MARK: - Previews

#Preview("Successful Load") {
    ThumbnailImage(
        viewModel: ThumbnailImageViewModel(
            url: URL(string: "https://img.jakpost.net/c/2019/09/03/2019_09_03_78912_1567484272._large.jpg")!
        )
    )
}

#Preview("Error Case") {
    ThumbnailImage(
        viewModel: ThumbnailImageViewModel(
            url: URL(string: "https://example.com")!
        )
    )
}
