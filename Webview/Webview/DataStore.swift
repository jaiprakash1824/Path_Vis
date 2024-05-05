//
//  DataStore.swift
//  Webview
//
//  Created by Guttikonda Partha Sai on 05/05/24.
//

import Foundation

class DataStore: ObservableObject {
    @Published var notes: [ResultsDisplay] = []
}
