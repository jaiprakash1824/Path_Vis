//
//  WebviewApp.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/16/24.
//

import SwiftUI

@main
struct WebviewApp: App {
    @State var results = ["A", "B", "C"]
    var body: some Scene {
        WindowGroup {
            ContentView(results: $results)
        }
        
        WindowGroup(id: "SecondWindow") {
            SecondView(results: $results)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
