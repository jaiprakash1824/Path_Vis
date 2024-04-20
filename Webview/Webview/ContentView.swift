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
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    func doit(){
        print("working wait")
    }
    
    var body: some View {
        //        VStack {
        //            WebView(url: URL(string: "http://10.64.1.105:5001")!).glassBackgroundEffect()
        //                .toolbar{
        //                    Button(action: doit) {
        //                        Label("Record Progress", systemImage: "book.circle")
        //                    }
        //                }
        //        }
        TabView {
            Text("Folders")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            WebView(url: URL(string: "http://10.64.1.105:5001/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!).glassBackgroundEffect()
                .tabItem {
                    Label("Viewer", systemImage: "eye")
                }
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
