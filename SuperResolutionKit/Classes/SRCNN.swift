//
// SRCNN.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class SRCNNInput : MLFeatureProvider {

    /// image as color (kCVPixelFormatType_32BGRA) image buffer, 200 pixels wide by 200 pixels high
    var image: CVPixelBuffer
    
    var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class SRCNNOutput : MLFeatureProvider {

    /// output1 as 3 x 200 x 200 3-dimensional array of doubles
    let output1: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["output1"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "output1") {
            return MLFeatureValue(multiArray: output1)
        }
        return nil
    }
    
    init(output1: MLMultiArray) {
        self.output1 = output1
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class SRCNN {
    var model: MLModel

    /**
        Construct a model with explicit path to mlmodel file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init(modelName: String) {
        let bundle = Bundle(for: SRCNN.self)
        let url = bundle.url(forResource: "SuperResolutionKit", withExtension: "bundle")!
        let srBundle = Bundle(url: url)!
        let assetPath = srBundle.url(forResource: modelName, withExtension: "mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as SRCNNInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as SRCNNOutput
    */
    func prediction(input: SRCNNInput) throws -> SRCNNOutput {
        let outFeatures = try model.prediction(from: input)
        let result = SRCNNOutput(output1: outFeatures.featureValue(for: "output1")!.multiArrayValue!)
        return result
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - image as color (kCVPixelFormatType_32BGRA) image buffer, 200 pixels wide by 200 pixels high
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as SRCNNOutput
    */
    func prediction(image: CVPixelBuffer) throws -> SRCNNOutput {
        let input_ = SRCNNInput(image: image)
        return try self.prediction(input: input_)
    }
}
