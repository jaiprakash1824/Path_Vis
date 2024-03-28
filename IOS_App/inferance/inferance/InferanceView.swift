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
                inferenceTriggering(modelDataCom: model);
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

func inferenceTriggering(modelDataCom: DataModel) {
    print("Inference triggering here")

    guard let imageData = modelDataCom.imageData,
          let image = UIImage(data: imageData) else {
        print("Error: Could not load image data.")
        return
    }

    do {
        // Convert UIImage to MLMultiArray
        let inputArray = try convertImageToMLMultiArray(image)

        // Load the custom model 'Segmentation_working'.
        let segmentationModel = try Segmentation_working(configuration: MLModelConfiguration())

        // Make prediction
        let prediction = try segmentationModel.prediction(image: inputArray) // Adjust 'image:' to your model's input name

        // Handle prediction result
        print(prediction.var_1764) // Adjust according to what your model outputs

    } catch {
        print("Error occurred: \(error.localizedDescription)")
    }
}

// Dummy function for converting UIImage to MLMultiArray
// Implement this function based on your model's input requirements
func convertImageToMLMultiArray(_ image: UIImage) throws -> MLMultiArray {
    let shape = [1, 3, 640, 640] as [NSNumber]
    guard let mlMultiArray = try? MLMultiArray(shape: shape, dataType: MLMultiArrayDataType.float32) else {
        throw NSError(domain: "MLMultiArrayInitializationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create MLMultiArray"])
    }
    return mlMultiArray
}

#Preview {
    InferanceView(model:DataModel())
}
