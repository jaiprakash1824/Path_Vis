//
//  SwiftUIView.swift
//  
//
//  Created by Guttikonda Partha Sai on 26/02/24.
//

import SwiftUI
import CoreML
import Vision
import CoreGraphics

struct InferanceView: View {
    @StateObject var model: DataModel;
    var body: some View {
        VStack {
            DisplayView(image:model.viewfinderImage)
            Text("Run Inferance 🙂")
                .font(.largeTitle);
            Button("Run", systemImage: "arrow.right") {
                inferanceTreggering(model: model);
            }.buttonStyle(.bordered)
        }
        
    }
}

struct DisplayView: View {
    var image: Image?
    
    var body: some View {
        ZStack {
            Color.white
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 200, height: 200)
        .cornerRadius(11)
    }
}

func inferanceTreggering(model: DataModel) {
    print("inferance triggering here")
//    print(model.thumbnailImage)
//    guard let resnetmodel = try?VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else {
//        fatalError("Issue in loading Resnet50 model")
//    }
//    let request = VNCoreMLRequest(model: resnetmodel) {(request, error) in
//        guard let results = request.results as? [VNClassificationObservation] else {
//            fatalError("Model filed to process image.")
//        }
//        print(results)
//    }
//    let image: CIImage;
//    print(model.photoCollection.photoAssets.next().publisher)
//    let handler = VNImageRequestHandler(ciImage:  (model.thumbnailImage?.ciImage)!,nil)
//    
//    do {
//        try handler.perform([request])
//    } catch {
//        print(error)
//    }
    
}



#Preview {
    InferanceView(model:DataModel())
}
