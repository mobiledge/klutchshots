//
//  ContentView.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import SwiftUI

struct ContentView: View {

    let networkService = NetworkService(
        session: URLSession.shared,
        imageCache: ImageCache()
    )

    var body: some View {
        TabView {

            // Videos Tab
            NavigationStack {
                VideoListView(
                    viewModel: VideoListViewModel(
                        networkService: networkService
                    )
                )
            }
            .tabItem {
                Label("Videos", systemImage: "play.rectangle")
            }

            // Downloads Tab
            NavigationStack {
                DownloadsView()
                    .navigationTitle("Downloads")
            }
            .tabItem {
                Label("Downloads", systemImage: "arrow.down.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}
