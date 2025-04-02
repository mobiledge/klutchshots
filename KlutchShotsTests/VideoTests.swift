import XCTest
@testable import KlutchShots

final class VideoTests: XCTestCase {

    // Sample video data
    let sampleVideoJSON = """
    [
        {
            "id": "1",
            "title": "Big Buck Bunny",
            "thumbnailUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png",
            "duration": "8:18",
            "uploadTime": "May 9, 2011",
            "views": "24,969,123",
            "author": "Vlc Media Player",
            "videoUrl": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "description": "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\\n\\nLicensed under the Creative Commons Attribution license\\nhttp://www.bigbuckbunny.org",
            "subscriber": "25254545 Subscribers",
            "isLive": true
        },
        {
            "id": "2",
            "title": "The first Blender Open Movie from 2006",
            "thumbnailUrl": "https://i.ytimg.com/vi_webp/gWw23EYM9VM/maxresdefault.webp",
            "duration": "12:18",
            "uploadTime": "May 9, 2011",
            "views": "24,969,123",
            "author": "Blender Inc.",
            "videoUrl": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "description": "Song : Raja Raja Kareja Mein Samaja\\nAlbum : Raja Kareja Mein Samaja\\nArtist : Radhe Shyam Rasia\\nSinger : Radhe Shyam Rasia\\nMusic Director : Sohan Lal, Dinesh Kumar\\nLyricist : Vinay Bihari, Shailesh Sagar, Parmeshwar Premi\\nMusic Label : T-Series",
            "subscriber": "25254545 Subscribers",
            "isLive": true
        }
    ]
    """

    // Test JSON encoding and decoding
    func testVideosDecoding() throws {
        let jsonData = sampleVideoJSON.data(using: .utf8)!
        let videos = try Videos(jsonData: jsonData)

        XCTAssertEqual(videos.count, 2)

        // Check first video properties
        XCTAssertEqual(videos[0].id, "1")
        XCTAssertEqual(videos[0].title, "Big Buck Bunny")
        XCTAssertEqual(videos[0].thumbnailUrl, URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png"))
        XCTAssertEqual(videos[0].duration, "8:18")
        XCTAssertEqual(videos[0].uploadTime, "May 9, 2011")
        XCTAssertEqual(videos[0].views, "24,969,123")
        XCTAssertEqual(videos[0].author, "Vlc Media Player")
        XCTAssertEqual(videos[0].videoUrl, URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
        XCTAssertEqual(videos[0].description, "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org")
        XCTAssertEqual(videos[0].subscriber, "25254545 Subscribers")
        XCTAssertTrue(videos[0].isLive)

        // Check second video properties
        XCTAssertEqual(videos[1].id, "2")
        XCTAssertEqual(videos[1].title, "The first Blender Open Movie from 2006")
        XCTAssertEqual(videos[1].thumbnailUrl, URL(string: "https://i.ytimg.com/vi_webp/gWw23EYM9VM/maxresdefault.webp"))
        XCTAssertEqual(videos[1].duration, "12:18")
        XCTAssertEqual(videos[1].uploadTime, "May 9, 2011")
        XCTAssertEqual(videos[1].views, "24,969,123")
        XCTAssertEqual(videos[1].author, "Blender Inc.")
        XCTAssertEqual(videos[1].videoUrl, URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"))
        XCTAssertTrue(videos[1].isLive)
    }

    func testVideosEncoding() throws {
        // Create a video array
        let videos: Videos = [
            Video(
                id: "1",
                title: "Big Buck Bunny",
                thumbnailUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png")!,
                duration: "8:18",
                uploadTime: "May 9, 2011",
                views: "24,969,123",
                author: "Vlc Media Player",
                videoUrl: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                description: "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org",
                subscriber: "25254545 Subscribers",
                isLive: true
            )
        ]

        // Encode to JSON data
        let jsonData = try videos.toJsonData()

        // Decode back to verify
        let decodedVideos = try Videos(jsonData: jsonData)

        XCTAssertEqual(decodedVideos.count, 1)
        XCTAssertEqual(decodedVideos[0].id, "1")
        XCTAssertEqual(decodedVideos[0].title, "Big Buck Bunny")
        XCTAssertEqual(decodedVideos[0].thumbnailUrl, URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png"))
        XCTAssertEqual(decodedVideos[0].duration, "8:18")
        XCTAssertEqual(decodedVideos[0].uploadTime, "May 9, 2011")
        XCTAssertEqual(decodedVideos[0].views, "24,969,123")
        XCTAssertEqual(decodedVideos[0].author, "Vlc Media Player")
        XCTAssertEqual(decodedVideos[0].videoUrl, URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
        XCTAssertEqual(decodedVideos[0].description, "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org")
        XCTAssertEqual(decodedVideos[0].subscriber, "25254545 Subscribers")
        XCTAssertTrue(decodedVideos[0].isLive)
    }

    // Test mock data loading
    func testMockDataLoading() {
        let mockVideos = Videos.mock
        XCTAssertFalse(mockVideos.isEmpty, "Mock videos should not be empty if videos.json is properly configured")
    }
}
