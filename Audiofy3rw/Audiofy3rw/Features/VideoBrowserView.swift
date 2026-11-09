import SwiftUI
import WebKit

@MainActor
final class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var addressText = "https://www.youtube.com"

    let webView: WKWebView = {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.allowsPictureInPictureMediaPlayback = true
        return WKWebView(frame: .zero, configuration: cfg)
    }()

    override init() {
        super.init()
        webView.navigationDelegate = self
        load(addressText)
    }

    func load(_ text: String) {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.lowercased().hasPrefix("http") { s = "https://" + s }
        guard let url = URL(string: s), let scheme = url.scheme, ["http", "https"].contains(scheme) else { return }
        webView.load(URLRequest(url: url))
    }

    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func reload() { webView.reload() }

    func teardown() {
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
    }

    private func sync() {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        isLoading = webView.isLoading
        if let u = webView.url?.absoluteString { addressText = u }
    }

    func webView(_ w: WKWebView, didStartProvisionalNavigation n: WKNavigation!) { sync() }
    func webView(_ w: WKWebView, didFinish n: WKNavigation!) { sync() }
    func webView(_ w: WKWebView, didFail n: WKNavigation!, withError e: Error) { sync() }
    func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) { sync() }
}

struct WebContainer: UIViewRepresentable {
    let model: WebViewModel
    func makeUIView(context: Context) -> WKWebView { model.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) { uiView.stopLoading() }
}

struct VideoBrowserView: View {
    @StateObject private var model = WebViewModel()
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { model.goBack() } label: { Image(systemName: "chevron.left") }.disabled(!model.canGoBack)
                Button { model.goForward() } label: { Image(systemName: "chevron.right") }.disabled(!model.canGoForward)
                TextField("URL", text: $model.addressText)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onSubmit { focused = false; model.load(model.addressText) }
                Button { model.reload() } label: { Image(systemName: "arrow.clockwise") }
            }
            .padding(8)
            if model.isLoading { ProgressView().progressViewStyle(.linear) }
            WebContainer(model: model)
        }
        .onAppear { AudioManager.shared.pause() }
        .onDisappear {
            model.webView.evaluateJavaScript("document.querySelectorAll('video').forEach(v => v.pause())")
        }
    }
}
