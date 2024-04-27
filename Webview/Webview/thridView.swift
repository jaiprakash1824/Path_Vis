//
//  thridView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/23/24.
//

import SwiftUI
import WebKit

struct thridView: View {
    
    @Binding var resultViweURL: String
    @State private var takeScreenshot = false
    @State private var rootIP = "http://127.0.0.1:5001/"
    
    func getURL() -> URL {
        print(resultViweURL)
        print(rootIP)
        let url = URL(string: (rootIP + resultViweURL))
        return url!
    }
    
    var body: some View {
        VStack {
            WebView(url: getURL(), takeScreenshot: $takeScreenshot)
            Text(resultViweURL)
        }
    }
}
