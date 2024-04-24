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
        List(results, id: \.self) { result in
            Text(result)
        }
    }
}
