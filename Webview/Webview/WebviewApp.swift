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
    @StateObject private var dataStore = DataStore()
    var body: some Scene {
        WindowGroup {
            ContentView(results: $results)
        }
        
        WindowGroup(id: "SecondWindow") {
            SecondView(results: $results, resultViweURL: $resultViweURL).environmentObject(dataStore)
        }
        
//        WindowGroup(id: "thridWindow") {
//            thridView(resultViweURL: $resultViweURL)
//        }
        
        WindowGroup("Note", for: ResultsDisplay.ID.self) { $noteId in
            thridView(noteId: noteId)
                        .environmentObject(dataStore)
                }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
