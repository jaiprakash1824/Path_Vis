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

    var body: some View {
        VStack {
            WebView(url: URL(string: "http://172.20.10.2:5001/")!)
                .glassBackgroundEffect()
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
