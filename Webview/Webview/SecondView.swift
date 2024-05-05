//
//  SecondView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/23/24.
//

import SwiftUI


struct SecondView: View {
    @Environment(\.openWindow) private var openWindow
    @Binding var results: Array<String>
    @Binding var resultViweURL: String
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Search Results")
                .font(.title)
            List(results, id: \.self) { result in
                Button(action: {
                    DispatchQueue.main.async {  // Ensure UI updates on the main thread
                        self.resultViweURL = result
//                        openWindow(id: "thridWindow")
                        var uniqueID = UUID()
                        var displayObject = ResultsDisplay(id: uniqueID, name: result)
                        dataStore.notes.append(displayObject)
                        openWindow(value: uniqueID)
                    }
                }) {
                    HStack {
                        Text(result)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Make the button expand to the full width
                    .background(Color.blue) // Change this to your preferred color
                    .cornerRadius(8) // Rounded corners for aesthetics
                    .padding(.vertical, 5) // Space between buttons
                }
            }
            .listStyle(PlainListStyle()) // Remove list lines
        }.padding()
        .padding(.top, 40)
    }
}
