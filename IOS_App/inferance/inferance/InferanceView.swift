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
        let prediction = try segmentationModel.prediction(image: inputArray)
        print(prediction.var_1764ShapedArray.shape)
//        print(prediction.var_1764ShapedArray[0])

        // Assuming a utility function exists to analyze the segmentation map and find the bounding box of the largest zero region
        if let boundingBox = findBoundingBoxOfLargestZeroRegion(fromMask: prediction.var_1764) {
            // Crop the image to this bounding box
            print("image hight :",image.size.height)
            print("image width :",image.size.width)
            if let croppedImage = cropImage(image, to: boundingBox) {
                // Use croppedImage as needed, e.g., display in UI or further processing
                modelDataCom.thumbnailImage = Image(uiImage: croppedImage)
                print("Successfully cropped the image.")
            } else {
                print("Error: Could not crop the image.")
            }
        } else {
            print("Error: Could not find a zero-value region to crop.")
        }

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

func findBoundingBoxOfLargestZeroRegion(fromMask mask: MLMultiArray) -> CGRect? {
    let height = mask.shape[1].intValue
    let width = mask.shape[2].intValue
    var minX = width
    var maxX = 0
    var minY = height
    var maxY = 0

    // Loop through the segmentation map to find the extents of the zero-valued region
    for y in 0..<height {
        for x in 0..<width {
            let index = [0, y, x] as [NSNumber]
            print(mask[index].intValue)
            if mask[index].intValue == 1 { // Assuming '0' is the value of interest
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
    }
    print("xMin -> ", minX)
    print("maxX -> ", maxX)
    print("minY -> ", minY)
    print("maxY -> ", maxY)
    // Ensure we have a valid region
    if minX <= maxX && minY <= maxY {
        // Convert to CGRect considering the origin is at top-left in UIKit
        let rect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        return rect
    } else {
        // No valid region found
        return nil
    }
}

func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    guard let croppedCgImage = cgImage.cropping(to: rect) else { return nil }
    return UIImage(cgImage: croppedCgImage)
}


#Preview {
    InferanceView(model:DataModel())
}
