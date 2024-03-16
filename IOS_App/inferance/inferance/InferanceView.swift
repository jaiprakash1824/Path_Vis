//
//  SwiftUIView.swift
//
//
//  Created by Guttikonda Partha Sai on 26/02/24.
//

import SwiftUI
import CoreML
import Vision

struct InferanceView: View {
    @StateObject var model: DataModel;
    var body: some View {
        VStack {
            DisplayView(image:model.thumbnailImage)
            Text("Run Inferance 🙂")
                .font(.largeTitle);
            Button("Run", systemImage: "arrow.right") {
                inferanceTreggering(modelDataCom: model);
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

func inferanceTreggering(modelDataCom: DataModel) {
    print("inferance triggering here")
//    print(model.thumbnailImage)
    var config = MLModelConfiguration()
    guard let model = try? VNCoreMLModel(for: Resnet50(configuration: config).model)
                else { return }
    let request = VNCoreMLRequest(model: model)
    { (finishedReq, err) in
        guard let results =
                finishedReq.results as? [VNClassificationObservation]
        else { return }
        guard let firstObservation = results.first
        else { return }
        print(firstObservation.identifier, firstObservation.confidence)
        DispatchQueue.main.async {
                        let confidenceRate = firstObservation.confidence * 100
                        let objectName = firstObservation.identifier
                        let result = "\(objectName) \(confidenceRate)"
                        print("results --> ",result)
                    }
    }
//    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(dataModelCom.thumbnailImageCvPixelBuffer as! CMSampleBuffer) else { return }
//    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    
}



#Preview {
    InferanceView(model:DataModel())
}
