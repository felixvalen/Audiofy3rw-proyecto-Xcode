import SwiftUI

struct MusicView: View {
    @ObservedObject private var audio = AudioManager.shared

    // Sustituir por un catálogo con derechos. Ejemplo:
    // Track(title: "Demo", artist: "Artista", url: URL(string: "https://tu-servidor/demo.mp3")!)
    private let demo: [Track] = []

    var body: some View {
        NavigationStack {
            Group {
                if demo.isEmpty {
                    ContentUnavailableView("Sin catálogo", systemImage: "music.note.list",
                        description: Text("Añade pistas en MusicView.demo"))
                } else {
                    List(demo) { track in
                        Button {
                            if let i = demo.firstIndex(of: track) { audio.setQueue(demo, startAt: i) }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(track.title).font(.headline)
                                Text(track.artist).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("audiofy 3rw")
            .safeAreaInset(edge: .bottom) { miniPlayer }
        }
    }

    @ViewBuilder private var miniPlayer: some View {
        if let t = audio.current {
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(t.title).font(.subheadline.bold())
                    Text(t.artist).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { audio.previous() } label: { Image(systemName: "backward.fill") }
                Button { audio.togglePlay() } label: { Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill") }
                Button { audio.next() } label: { Image(systemName: "forward.fill") }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
