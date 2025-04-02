# KlutchShots

## Architecture

The KlutchShots iOS application is built using the **Model-View-ViewModel (MVVM)** architectural pattern. This structure promotes separation of concerns, making the codebase more maintainable, testable, and scalable.

*   **Model:** Represents the data and business logic. In KlutchShots, this includes data models for videos, user profiles, and any other relevant data.
*   **View:** The user interface layer, built with UIKit. Views are responsible for displaying data and capturing user interactions.
*   **ViewModel:** Acts as an intermediary between the Model and the View. It prepares data for display, handles user input, and updates the Model. ViewModels contain presentation logic and are responsible for managing the state of the View.

#### Buffering

`AVPlayer` automatically handles buffering of video content. You can monitor the `AVPlayer`'s `status` property to determine buffering state. Implement logic to display loading indicators while buffering. Key properties for monitoring buffering include `timeControlStatus` and `reasonForWaitingToPlay`.

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
