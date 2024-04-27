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
    @State var resultViweURL = ""
    var body: some Scene {
        WindowGroup {
            ContentView(results: $results)
        }
        
        WindowGroup(id: "SecondWindow") {
            SecondView(results: $results, resultViweURL: $resultViweURL)
        }
        
        WindowGroup(id: "thridWindow") {
            thridView(resultViweURL: $resultViweURL)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
