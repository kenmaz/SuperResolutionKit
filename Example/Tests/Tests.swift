import XCTest
import SuperResolutionKit

class Tests: XCTestCase {
    
    func test() {
        let img = #imageLiteral(resourceName: "color")
        let buff = img.pixelBuffer(width: Int(img.size.width), height: Int(img.size.height))!
        //print(buff)
        
        CVPixelBufferLockBaseAddress(buff, [])
        let baseAddr = CVPixelBufferGetBaseAddress(buff)
        let cap = Int(img.size.width * img.size.height * 3.0)
        let ptr = baseAddr?.bindMemory(to: UInt8.self, capacity: cap)
        
        for i in (0...cap) {
            if let val = ptr?.advanced(by: i).pointee {
                print(val)
            }
        }

        CVPixelBufferUnlockBaseAddress(buff, [])
        
    }
    
}
