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
    // DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)
    let segmentationModel = DeepLabV3()
        
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel1: VNCoreMLModel?

    if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
        visionModel1 = visionModel
        request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        request?.imageCropAndScaleOption = .centerCrop
    } else {
        fatalError()
    }
    guard let request = request else { fatalError() }
    // vision framework configures the input size of image following our model's input configuration automatically
    let handler = VNImageRequestHandler(cgImage: (UIImage(data: modelDataCom.imageData!)?.cgImage)!, options: [:])
    try? handler.perform([request])
    
    //    print(model.thumbnailImage)
//    let imagePredictor = ImagePredictor()
//    do {
//        try imagePredictor.makePredictions(for: UIImage(data: modelDataCom.imageData!)!,
//                                                completionHandler: imagePredictionHandler)
//    } catch {
//        print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
//    }
//    func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
//        guard let predictions = predictions else {
//            print("No predictions. (Check console log.)")
//            return
//        }
//        
//        print(predictions)
//    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationmap = observations.first?.featureValue.multiArrayValue {
                print(segmentationmap)
            }
        }
}



#Preview {
    InferanceView(model:DataModel())
}
