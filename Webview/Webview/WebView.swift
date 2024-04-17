//
//  WebView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/16/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        return WKWebView(frame: .zero, configuration: config)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
