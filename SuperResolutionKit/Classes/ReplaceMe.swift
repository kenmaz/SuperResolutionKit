import CoreML

public class SuperResolutionKit {
    public static func hello() {
        print("world")
        let bundle = Bundle(for: self)
        let url = bundle.url(forResource: "SuperResolutionKit", withExtension: "bundle")!
        let srBundle = Bundle(url: url)!
        let modelUrl = srBundle.url(forResource: "SRCNN", withExtension: "mlmodelc")!
        let model = try! MLModel(contentsOf: modelUrl)
        
        print(model)
    }
}
