//
//  WebviewApp.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/16/24.
//

import SwiftUI

@main
struct WebviewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
