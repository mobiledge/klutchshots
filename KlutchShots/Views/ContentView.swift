import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            VideoListView(viewModel: VideoListViewModel())
        }
    }
}

#Preview {
    ContentView()
}
