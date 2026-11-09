import AVFoundation
import MediaPlayer

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let url: URL
}

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published private(set) var isPlaying = false
    @Published private(set) var current: Track?
    @Published private(set) var queue: [Track] = []

    private let player = AVPlayer()
    private var index = 0
    private var observers: [NSObjectProtocol] = []
    private var configured = false

    func configure() {
        guard !configured else { return }
        configured = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)

        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            let opts = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            Task { @MainActor in
                if type == .began { self?.pause() }
                else if AVAudioSession.InterruptionOptions(rawValue: opts).contains(.shouldResume) { self?.play() }
            }
        })
        observers.append(nc.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable else { return }
            Task { @MainActor in self?.pause() }
        })
        observers.append(nc.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.next() }
        })

        let c = MPRemoteCommandCenter.shared()
        c.playCommand.addTarget { [weak self] _ in Task { @MainActor in self?.play() }; return .success }
        c.pauseCommand.addTarget { [weak self] _ in Task { @MainActor in self?.pause() }; return .success }
        c.nextTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.next() }; return .success }
        c.previousTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.previous() }; return .success }
    }

    func setQueue(_ tracks: [Track], startAt i: Int = 0) { queue = tracks; load(i); play() }
    func play() { player.play(); isPlaying = true; updateNowPlaying() }
    func pause() { player.pause(); isPlaying = false; updateNowPlaying() }
    func togglePlay() { isPlaying ? pause() : play() }

    func next() {
        guard index + 1 < queue.count else { pause(); return }
        load(index + 1); play()
    }
    func previous() {
        guard index > 0 else { player.seek(to: .zero); return }
        load(index - 1); play()
    }

    private func load(_ i: Int) {
        guard queue.indices.contains(i) else { return }
        index = i
        current = queue[i]
        player.replaceCurrentItem(with: AVPlayerItem(url: queue[i].url))
    }

    private func updateNowPlaying() {
        guard let t = current else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: t.title,
            MPMediaItemPropertyArtist: t.artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime().seconds,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
}
