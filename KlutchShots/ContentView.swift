//
//  ContentView.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import SwiftUI

struct ContentView: View {

    @State var repo = VideoRepository(api: VideoAPI())

    var body: some View {
        VideoListView(viewModel: VideoListViewModel(repository: repo))
    }
}

#Preview {
    ContentView()
}
