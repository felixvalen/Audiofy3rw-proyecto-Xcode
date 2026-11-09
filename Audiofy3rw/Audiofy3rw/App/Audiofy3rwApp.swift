import SwiftUI

@main
struct Audiofy3rwApp: App {
    init() { AudioManager.shared.configure() }
    var body: some Scene { WindowGroup { RootView() } }
}

struct RootView: View {
    var body: some View {
        TabView {
            MusicView().tabItem { Label("Música", systemImage: "music.note") }
            VideoBrowserView().tabItem { Label("Vídeos", systemImage: "play.rectangle") }
        }
    }
}
