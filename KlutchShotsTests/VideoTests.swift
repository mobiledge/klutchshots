import Foundation
import Testing

struct VideoTests {
    // Test fixture
    let videoFixture = """
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

    @Test func decodeVideoArray() async throws {
        // When
        let jsonData = videoFixture.data(using: .utf8)!
        let videos = try Video.decodeArray(from: jsonData)

        // Then
        #expect(videos.count == 2)

        // First video assertions
        #expect(videos[0].id == "1")
        #expect(videos[0].title == "Big Buck Bunny")
        #expect(videos[0].isLive == true)

        // Second video assertions
        #expect(videos[1].id == "2")
        #expect(videos[1].title == "The first Blender Open Movie from 2006")
        #expect(videos[1].duration == "12:18")
        #expect(videos[1].isLive == true)
    }
}
