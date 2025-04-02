import XCTest
@testable import KlutchShots

class VideoTests: XCTestCase {

    // MARK: - Test Single Video Decoding
    func testVideoDecoding() throws {
        let json = """
        {
            "id": "1",
            "title": "Big Buck Bunny",
            "thumbnailUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png",
            "duration": "8:18",
            "uploadTime": "May 9, 2011",
            "views": "24,969,123",
            "author": "Vlc Media Player",
            "videoUrl": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "description": "Big Buck Bunny tells the story of a giant rabbit...",
            "subscriber": "25254545 Subscribers",
            "isLive": true
        }
        """.data(using: .utf8)!

        let video = try JSONDecoder().decode(Video.self, from: json)

        XCTAssertEqual(video.id, "1")
        XCTAssertEqual(video.title, "Big Buck Bunny")
        XCTAssertEqual(video.thumbnailUrl.absoluteString, "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png")
        XCTAssertEqual(video.duration, "8:18")
        XCTAssertEqual(video.uploadTime, "May 9, 2011")
        XCTAssertEqual(video.views, "24,969,123")
        XCTAssertEqual(video.author, "Vlc Media Player")
        XCTAssertEqual(video.videoUrl.absoluteString, "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        XCTAssertNotNil(video.description)
        XCTAssertEqual(video.subscriber, "25254545 Subscribers")
        XCTAssertTrue(video.isLive)
    }

    // MARK: - Test Videos Array Decoding
    func testVideosArrayDecoding() throws {
        let json = """
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
                "description": "Big Buck Bunny tells the story...",
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
                "description": "Song : Raja Raja Kareja Mein Samaja...",
                "subscriber": "25254545 Subscribers",
                "isLive": true
            }
        ]
        """.data(using: .utf8)!

        let videos = try Videos(jsonData: json)

        XCTAssertEqual(videos.count, 2)

        // Test first video
        XCTAssertEqual(videos[0].id, "1")
        XCTAssertEqual(videos[0].title, "Big Buck Bunny")
        XCTAssertEqual(videos[0].author, "Vlc Media Player")

        // Test second video
        XCTAssertEqual(videos[1].id, "2")
        XCTAssertEqual(videos[1].title, "The first Blender Open Movie from 2006")
        XCTAssertEqual(videos[1].author, "Blender Inc.")
    }

    // MARK: - Test Encoding and Decoding Roundtrip
    func testEncodingDecodingRoundtrip() throws {
        let json = """
        {
            "id": "1",
            "title": "Big Buck Bunny",
            "thumbnailUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png",
            "duration": "8:18",
            "uploadTime": "May 9, 2011",
            "views": "24,969,123",
            "author": "Vlc Media Player",
            "videoUrl": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "description": "Big Buck Bunny tells the story...",
            "subscriber": "25254545 Subscribers",
            "isLive": true
        }
        """.data(using: .utf8)!

        let originalVideo = try JSONDecoder().decode(Video.self, from: json)
        let encodedData = try JSONEncoder().encode(originalVideo)
        let decodedVideo = try JSONDecoder().decode(Video.self, from: encodedData)

        XCTAssertEqual(originalVideo.id, decodedVideo.id)
        XCTAssertEqual(originalVideo.title, decodedVideo.title)
        XCTAssertEqual(originalVideo.thumbnailUrl, decodedVideo.thumbnailUrl)
        XCTAssertEqual(originalVideo.videoUrl, decodedVideo.videoUrl)
        XCTAssertEqual(originalVideo.isLive, decodedVideo.isLive)
    }
}
