//
//  Video.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//


import Foundation

struct Video: Codable {
    let id: String
    let title: String
    let thumbnailUrl: String
    let duration: String
    let uploadTime: String
    let views: String
    let author: String
    let videoUrl: String
    let description: String?
    let subscriber: String?
    let isLive: Bool
}


// Example of decoding JSON data
extension Video {
    static func decodeArray(from jsonData: Data) throws -> [Video] {
        let decoder = JSONDecoder()
        return try decoder.decode([Video].self, from: jsonData)
    }
}

// Mocks
extension Video {

    static func mockSuccessResponse(request: URLRequest) -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        let data = mockData()
        return (data, response)
    }

    static func mockArray() -> [Video] {
        let data = bundleContents("videos.json")
        return try! Video.decodeArray(from: data)
    }

    static func mockData() -> Data {
        bundleContents("videos.json")
    }
}

func bundleContents(_ resource: String) -> Data {
    let url = Bundle.main.url(forResource: resource, withExtension: nil)!
    let data = try! Data(contentsOf: url)
    return data
}
