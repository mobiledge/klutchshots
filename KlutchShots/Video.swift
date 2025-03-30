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
