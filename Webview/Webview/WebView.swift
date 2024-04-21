import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    @Binding var takeScreenshot: Bool
    var completion: ((UIImage?) -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        return WKWebView(frame: .zero, configuration: config)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if takeScreenshot {
            let snapshotConfiguration = WKSnapshotConfiguration()
            // Configure your snapshot here (e.g., specify snapshot bounds)
            uiView.takeSnapshot(with: snapshotConfiguration) { image, error in
                guard let image = image, error == nil else {
                    // Handle error
                    self.completion?(nil)
                    return
                }
                
                self.completion?(image)
            }
            // Reset the trigger to avoid repeated snapshots
            DispatchQueue.main.async {
                self.takeScreenshot = false
            }
        }else {
            let request = URLRequest(url: url)
            uiView.load(request)
        }

    }
}
