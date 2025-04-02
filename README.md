# KlutchShots

## Architecture

The KlutchShots app adopts a Model-View-ViewModel (MVVM) architecture to separate concerns and improve testability. The UI is built using SwiftUI. The app's data flow is unidirectional, driven by view models that interact with services to fetch and process data.

#### UI & Data Flow

1.  `ContentView` starts with `VideoListView`.
2.  `VideoListView` uses `VideoListViewModel` to fetch video data.
3.  `VideoListViewModel` fetches data using `NetworkService` and updates `loadingState`.
4.  `VideoListView` updates UI based on `loadingState`.
5.  Selecting a video navigates to `VideoDetailView`.
6.  `VideoDetailView` displays info via `VideoDetailViewModel` and plays video with `VideoPlayerView`.
7.  `VideoPlayerView` uses `VideoPlayerViewModel` and `AVPlayer` to play.
8.  `DownloadView` (within `VideoDetailView`) with `DownloadViewModel` handles video downloads.


#### Video Playback

`VideoPlayerViewModel` manages the `AVPlayer` and monitors its state. It updates the `playerState` property to reflect changes in the player's status (e.g., loading, ready to play, or error). 

`VideoPlayerView` observes the `playerState` and updates the UI accordingly, showing the video, a loading indicator, or an error message. Combine is used for asynchronous event handling between the player and the view model.

#### Download Handling

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


## Build and Run Instructions

### Prerequisites

*   macOS with Xcode installed
*   CocoaPods
*   iOS device or simulator

### Steps

1.  **Clone the Repository:**

    ```
    git clone https://github.com/mobiledge/klutchshots.git
    cd klutchshots
    ```

2.  **Open the Project:**

    Open `KlutchShots.xcworkspace` in Xcode.
    
4.  **Build and Run:**

    *   Select your target device (or simulator).
    *   Press the "Play" button (or `Cmd + R`) to build and run the app.
