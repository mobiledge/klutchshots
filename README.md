# KlutchShots

https://github.com/user-attachments/assets/a79d562f-73d0-4f27-a702-6f613584419e

## Architecture

The KlutchShots app adopts a Model-View-ViewModel (MVVM) architecture to separate concerns and improve testability. The UI is built using SwiftUI. The app's data flow is unidirectional, driven by view models that interact with services to fetch and process data.

### UI & Data Flow

1. `ContentView` starts with `VideoListView`.
2. `VideoListView` uses `VideoListViewModel` to fetch video data (using `NetworkService`) and updates UI based on `loadingState`.
3. Selecting a video navigates to `VideoDetailView`.
6. `VideoDetailView` displays info via `VideoDetailViewModel` and plays video with `VideoPlayerView`.
7. `VideoPlayerView` uses `VideoPlayerViewModel` and `AVPlayer` to play.
8. `DownloadView` (within `VideoDetailView`) with `DownloadViewModel` handles video downloads.


### Video Playback

`VideoPlayerViewModel` manages the `AVPlayer` and monitors its state. It updates the `playerState` property to reflect changes in the player's status (e.g., loading, ready to play, or error). 

`VideoPlayerView` observes the `playerState` and updates the UI accordingly, showing the video, a loading indicator, or an error message. Combine is used for asynchronous event handling between the player and the view model.

### Download Handling

`ImageCache` is designed to cache images downloaded from URLs. It stores images in the app's cache directory, minimizing network requests and improving performance. An in-memory cache (e.g., `NSCache`) could be implemented to further enhance performance.

```swift
let image = await ImageCache.shared.fetch(for: imageUrl)
await ImageCache.shared.save(myImage, for: imageUrl)
await ImageCache.shared.clearCache()
```

`NetworkService` helps get data (like video info) and images from the network. It uses `ImageCache` to cache downloaded images abd checks if it already saved them before downloading again.

```swift
let videos = try await NetworkService.shared.fetchVideos() // Get a list of videos
let image = try await NetworkService.shared.fetchImage(from: imageUrl) // Get an image:
```

`VideoDownloader` lets you download files from the internet and keeps you updated on the progress. It uses Combine. It tells you how much of the file has been downloaded and let you stop the download at any time.

```swift
VideoDownloader()
.downloadWithProgress(from: fileURL)
.sink(receiveCompletion: { completion in
    // Download finished or failed with error
    }
}, receiveValue: { result in
    // Download progress & temp URL of downloaded file
    }
})
```

### Tests

The following tests have been implemented particularly focusing on the data access layer:

* `DataUtilsTests`: Tests for JSON encoding/decoding and bundle resource loading.
* `VideoTests`: Tests for `Video` model encoding, decoding, and mock data loading.
* `ImageCacheTests`: Tests for saving, fetching, and managing cached images.
* `NetworkServiceTests`: Tests for fetching video data and images from the network. 
* `VideoDownloaderTests`: Tests for download progress, completion, and cancellation.
* `VideoListViewModelTests`: Tests covering initial loading state, successful video fetching, error handling etc.

Note that tests for other View Models (like `VideoDetailViewModel`, `VideoPlayerViewModel`, and `DownloadViewModel`) are not currently implemented, but could be added following a similar approach to `VideoListViewModelTests`.



## Improvements

The following features and improvements would be great but I couldn't get to:

- In-memory cache: Currently images are saved to the caches folder with no triggers to clear cache based on size or expiration.
- Video download management: Videos are currently downloaded to temp folder but should be moved to downloads once complete. The UI needs updating to reflect if a video is already downloaded, and subsequent plays should use the local file.
- Custom SwiftUI transitions between video list and detail views using namespace (attempted but removed due to implementation issues).
- Additional unit tests for other view models (VideoDetailViewModel, VideoPlayerViewModel, and DownloadViewModel).
- General app improvements including localization, accessibility features, and dark mode support.

## Build and Run Instructions

1.  **Clone the Repository:**

    ```
    git clone https://github.com/mobiledge/klutchshots.git
    cd klutchshots
    ```

2.  **Open the Project:**

    Open `KlutchShots.xcodeproj` in Xcode.
    
4.  **Build and Run:**

    *   Select your target device (or simulator).
    *   Press the "Play" button (or `Cmd + R`) to build and run the app.
