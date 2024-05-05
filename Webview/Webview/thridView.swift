//
//  thridView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/23/24.
//

import SwiftUI
import WebKit

struct thridView: View {
    @EnvironmentObject var dataStore: DataStore
    let noteId: UUID?
    //    @Binding var resultViweURL: String
    @State private var takeScreenshot = false
    @State private var rootIP = "http://129.107.206.21:5001/"
    
    func getURL() -> URL {
        //        print(resultViweURL)
        print(rootIP)
        let url = URL(string: (rootIP))
        return url!
    }
    
    var body: some View {
        VStack {
//                        WebView(url: getURL(), takeScreenshot: $takeScreenshot)
//            Text(noteId!.uuidString)
            if let index = dataStore.notes.firstIndex(
                where: { $0.id == noteId }
            ) {
                Text(dataStore.notes[index].name)
            } else {
                // If we ended up here, it means that the note detail window was state restored by SwiftUI, but we didn't implement data persistence, so we can't show the note.
                Text("Couldn't find the presented note, because data persistence is not implemented in this sample project")
            }
        }
    }
}
