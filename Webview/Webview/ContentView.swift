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
    @State private var capturedImage: UIImage = UIImage()
    @State private var showingCapturedImageSheet = false
    @State var webViewURL = URL(string: "http://cse-133725.uta.edu:5001/brain/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
    @State var selection: Tab = Tab.home
    
    func doit(){
        print("working wait")
    }
    
    var body: some View {
        TabView(selection: $selection) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left side (25%)
                    VStack {
                        Button(action: {
                            self.webViewURL = URL(string: "http://cse-133725.uta.edu:5001/brain/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
                            self.selection = Tab.viwer
                        }, label: {
                            Text("Image 1")
                        })
                    }
                    .frame(width: geometry.size.width * 0.25)
                    .background(Color.gray)
                    // Right side (75%)
                    VStack {
                        // Your files content here
                        Button(action: {
                            self.webViewURL = URL(string: "http://cse-133725.uta.edu:5001/brain/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
                            self.selection = Tab.viwer
                        }, label: {
                            Text("Image 2")
                        })
                    }
                    .frame(width: geometry.size.width * 0.75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }.tag(Tab.home)
            VStack {
                WebView(url: webViewURL, takeScreenshot: $takeScreenshot) { image in
//                    DispatchQueue.main.async {
//                        if let validImage = image {
//                            self.capturedImage = validImage
//                            print("Image captured ", validImage)
//                            
//                            // Save the image to the Photos album
//                            UIImageWriteToSavedPhotosAlbum(validImage, nil, nil, nil)
//                            
//                            self.showingCapturedImageSheet = true
//                        }
//                    }
                    self.capturedImage = image!
                    print("Image captured ", image)
                    self.showingCapturedImageSheet = true
                }.toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                        
                    }
                }.ornament(visibility: .visible, attachmentAnchor: .scene(.bottom), contentAlignment: .center) {
                    Button(action: {
                        self.takeScreenshot = true
                    }) {
                        Label("", systemImage: "camera.viewfinder")
                    }
                    .padding(.top, 50)
                }
                
            }.glassBackgroundEffect()
                .tabItem {
                    Label("Viewer", systemImage: "eye")
                }.tag(Tab.viwer)
        }.sheet(isPresented: $showingCapturedImageSheet) {
            Button(action: {
                self.showingCapturedImageSheet = false
            }, label: {
                Text("close")
            })
            // This is the sheet presentation of the captured image
            Image(uiImage: self.capturedImage)
                .resizable()
                .scaledToFit()
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
