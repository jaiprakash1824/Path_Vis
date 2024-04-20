//
//  ContentView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import WebKit

struct ContentView: View {
    
    @State private var takeScreenshot = false
    @State private var capturedImage: UIImage?
    let webViewURL = URL(string: "http://10.64.1.105:5001/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
    
    func doit(){
        print("working wait")
    }
    
    var body: some View {
        TabView {
            Text("Folders")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            VStack {
                        WebView(url: webViewURL, takeScreenshot: $takeScreenshot) { image in
                            self.capturedImage = image
                            // Handle captured image (e.g., show in the UI or save)
                        }
                        Button("Capture Screenshot") {
                            self.takeScreenshot = true
                        }
                    }.glassBackgroundEffect()
                .tabItem {
                    Label("Viewer", systemImage: "eye")
                }
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
