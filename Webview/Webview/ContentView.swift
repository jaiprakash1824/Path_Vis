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

enum Tab {
    case viwer
    case home
    case second
}

struct ContentView: View {
    
    @State private var takeScreenshot = false
    @State private var capturedImage: UIImage?
    @State var webViewURL = URL(string: "http://10.64.1.105:5001")!
    @State var selection: Tab = Tab.home
    
    func doit(){
        print("working wait")
    }
    
    var body: some View {
        TabView(selection: $selection) {
            HStack {
                Button("TCGA-12-0703") {
                    self.webViewURL = URL(string: "http://10.64.1.105:5001/GBM/TCGA-12-0703-01Z-00-DX1.c09bd51d-9a48-446a-a9fd-d4138f76c11c.svs")!
                    self.selection = Tab.viwer
                }
                Button("TCGA-DU-6400") {
                    self.webViewURL = URL(string: "http://10.64.1.105:5001/LGG/TCGA-DU-6400-01A-01-TS1.2fd5b56f-fa60-4985-ac9a-4964beb9262d.svs")!
                    self.selection = Tab.viwer
                }
            }
                .tabItem {
                    Label("Home", systemImage: "house")
                }.tag(Tab.home)
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
                }.tag(Tab.viwer)
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
