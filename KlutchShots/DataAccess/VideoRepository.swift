//
//  VideoRepository.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import Foundation

@Observable
@MainActor
class VideoRepository {

    static let live = VideoRepository(api: .live)
    static let mock = VideoRepository(api: .mock)

    private let api: VideoAPI
    private(set) var videos: [Video] = []

    init(api: VideoAPI) {
        self.api = api
    }

    @discardableResult
    func fetchAllVideos() async throws -> [Video] {
        do {
            let fetchedVideos = try await api.fetchAllVideos()
            videos = fetchedVideos
            return fetchedVideos
        } catch {
            videos = [] // Clear videos on error
            throw error
        }
    }
}
