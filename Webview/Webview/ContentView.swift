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
    @Binding var results: Array<String>
    @Environment(\.openWindow) private var openWindow
    @State private var takeScreenshot = false
    @State private var capturedImage: UIImage = UIImage()
    @State private var showingCapturedImageSheet = false
    //    @State private var rootIP = "http://172.20.10.3:5001"
    //    @State var webViewURL = URL(string: "http://172.20.10.3:5001/brain/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
    @State private var rootIP = "http://127.0.0.1:5001"
    @State var webViewURL = URL(string: "http://127.0.0.1:5001/brain/GBM/TCGA-02-0004-01Z-00-DX1.d8189fdc-c669-48d5-bc9e-8ddf104caff6.svs")!
    @State var selection: Tab = Tab.home
    @State var searchResult: Array<String> = Array()
    @State var displayImages: Array<String> = Array()
    @State var folderToBeDisplayed: Array<String> = ["brain/GBM","brain/LGG","breast/BRCA","colon/COAD", "liver/CHOL", "liver/LIHC", "lung/LUAD", "lung/LUSC"]
    
    
    func fetchStringsFromAPI(apiURL: String, completion: @escaping ([String]?, Error?) -> Void) {
        // Ensure the URL is valid
        guard let url = URL(string: apiURL) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle the error scenario
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Ensure the data is not nil
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Attempt to decode the data into an array of strings
            do {
                let strings = try JSONDecoder().decode([String].self, from: data)
                completion(strings, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        // Start the network request
        task.resume()
    }
    
    func getsearch() {
        let apiURL = rootIP+"/search" + webViewURL.path
        print(apiURL)
        openWindow(id: "SecondWindow")
        fetchStringsFromAPI(apiURL: apiURL) { strings, error in
            if let error = error {
                print("Error fetching strings: \(error)")
            } else if let strings = strings {
                DispatchQueue.main.async {  // Ensure UI updates on the main thread
                    self.results = strings
                    print("Received strings: \(strings)")
                }
            }
        }
    }
    
    func getDisplayImages(path: String) {
        let apiURL = rootIP+"/files/"+path
        print(apiURL)
        fetchStringsFromAPI(apiURL: apiURL) { strings, error in
            if let error = error {
                print("Error fetching strings: \(error)")
            } else if let strings = strings {
                DispatchQueue.main.async {  // Ensure UI updates on the main thread
                    self.displayImages = strings
                    print("Received strings: \(strings)")
                }
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selection) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left side (25%)
                    List {
                        ForEach(folderToBeDisplayed, id: \.self) { item in
                            Button(action: {
                                getDisplayImages(path: item)
                            }, label: {
                                Text(item)
                            })
                        }
                    }
                    .padding(.all)
                    .frame(width: geometry.size.width * 0.25)
                    .background(Color.gray)
                    // Right side (75%)
                    //                    ScrollView(.vertical, showsIndicators: true) {
                    //                        VStack {
                    //                            ForEach(displayImages, id: \.self) { imageUrl in
                    //                                Button(action: {
                    //                                    self.webViewURL = URL(string: "\(rootIP)\(imageUrl)")!
                    //                                    self.selection = Tab.viwer
                    //                                }, label: {
                    //                                    AsyncImage(url: URL(string: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")) { image in
                    //                                        image
                    //                                            .resizable()
                    //                                            .scaledToFit()
                    //                                            .frame(height: 150)
                    //                                    } placeholder: {
                    //                                        // Placeholder content while the image is loading
                    //                                        ProgressView()
                    //                                    }
                    //                                    let components = imageUrl.components(separatedBy: "/")
                    //                                    if let lastComponent = components.last {
                    //                                        Text(lastComponent)
                    //                                            .padding(.vertical, 5)
                    //                                            .foregroundColor(.white)
                    //                                    }
                    //
                    //                                })
                    //                            }
                    //                            .frame(width: geometry.size.width * 0.75)
                    //                        }
                    //                    }
                    List {
                        ForEach(displayImages, id: \.self) { imageUrl in
                            Button(action: {
                                self.webViewURL = URL(string: "\(rootIP)\(imageUrl)")!
                                self.selection = Tab.viwer
                            }, label: {
                                //                                AsyncImage(url: URL(string: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")) { image in
                                let components = imageUrl.components(separatedBy: "/")
                                if let lastComponent = components.last {
                                    Text(lastComponent)
                                        .padding(.vertical, 5)
                                        .foregroundColor(.white)
                                }
                                
                            })
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }.tag(Tab.home)
            VStack {
                WebView(url: webViewURL, takeScreenshot: $takeScreenshot) { image in
                    DispatchQueue.main.async {
                        if let validImage = image {
                            self.capturedImage = validImage
                            print("Image captured ", validImage)
                            
                            // Save the image to the Photos album
                            UIImageWriteToSavedPhotosAlbum(validImage, nil, nil, nil)
                            
                            self.showingCapturedImageSheet = true
                        }
                    }
                    self.capturedImage = image!
                    self.showingCapturedImageSheet = true
                }.toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                        
                    }
                }.ornament(visibility: .visible, attachmentAnchor: .scene(.bottom), contentAlignment: .center) {
                    HStack {
                        Button(action: {
                            print("open window Action")
                            getsearch()
                        }) {
                            Label("", systemImage: "magnifyingglass")
                        }
                        .padding(.top, 50)
                        Button(action: {
                            self.takeScreenshot = true
                        }) {
                            Label("", systemImage: "camera.viewfinder")
                        }
                        .padding(.top, 50)
                    }
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

//#Preview(windowStyle: .automatic) {
//    ContentView()
//}
