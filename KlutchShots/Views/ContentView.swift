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
        NavigationStack {
            VideoListView(
                viewModel: VideoListViewModel(
                    networkService: networkService
                )
            )
        }
    }
}

#Preview {
    ContentView()
}
