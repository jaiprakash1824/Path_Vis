//
//  SecondView.swift
//  Webview
//
//  Created by Jai Prakash Veerla on 4/23/24.
//

import SwiftUI

struct SecondView: View {
    
    @Binding var results: Array<String>
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Search Results")
                .font(.title)
            List(results, id: \.self) { result in
                Button(action: {
                    print(result)
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
