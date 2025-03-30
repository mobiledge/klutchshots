//
//  ContentView.swift
//  KlutchShots
//
//  Created by Rabin Joshi on 2025-03-30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VideoListView(videos: Video.mockArray())
    }
}

#Preview {
    ContentView()
}
