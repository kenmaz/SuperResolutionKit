//
//  FSRCNNConverter.swift
//  SuperResolutionKit
//
//  Created by Kentaro Matsumae on 2018/07/14.
//

import Foundation
import UIKit
import CoreML

public class FSRCNNConverter {
    
    public static let shared = FSRCNNConverter()
    private let shrinkSize = 0
    
    private let patchInSize = 100
    private let patchOutSize = 200
    private let model = SRCNN(modelName: "FSRCNN")
    
    private func resize2x(src: UIImage) -> UIImage? {
        let w = src.size.width
        let h = src.size.height
        let targetSize = CGSize(width: w * 2, height: h * 2)
        UIGraphicsBeginImageContext(targetSize)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.interpolationQuality = CGInterpolationQuality.high
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: targetSize.height)
        ctx.concatenate(transform)
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        ctx.draw(src.cgImage!, in: rect)
        let dst = UIGraphicsGetImageFromCurrentImageContext()
        return dst
    }
    
    private func expand(src: UIImage) -> UIImage? {
        let w = Int(src.size.width)
        let h = Int(src.size.height)
        let exW = w + shrinkSize * 2
        let exH = h + shrinkSize * 2
        let targetSize = CGSize(width: exW, height: exH)
        
        UIGraphicsBeginImageContext(targetSize)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.addRect(CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        ctx.drawPath(using: .fill)
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: targetSize.height)
        ctx.concatenate(transform)
        let rect = CGRect(x: shrinkSize, y: shrinkSize, width: w, height: h)
        ctx.draw(src.cgImage!, in: rect)
        let dst = UIGraphicsGetImageFromCurrentImageContext()
        return dst
    }
    
    struct PatchIn {
        let buff: CVPixelBuffer
        let position: CGPoint
    }
    struct PatchOut {
        let buff: MLMultiArray
        let position: CGPoint
    }
    
    struct Patch {
        let patchOutImage: CGImage
        let position: CGPoint
    }
    
    private func crop(src: UIImage) -> [PatchIn] {
        var patchesIn: [PatchIn] = []
        
        guard let cgimage = src.cgImage else {
            return []
        }
        let numY = Int(src.size.height) / patchInSize
        let numX = Int(src.size.width) / patchInSize
        
        for y in 0..<numY {
            for x in 0..<numX {
                let rect = CGRect(x: x * patchInSize, y: y * patchInSize, width: patchInSize, height: patchInSize)
                guard let cropped = cgimage.cropping(to: rect) else  {
                    fatalError()
                    continue
                }
                guard let buff = UIImage(cgImage: cropped).pixelBuffer(width: patchInSize, height: patchInSize) else {
                    fatalError()
                    continue
                }
                let patchIn = PatchIn(buff: buff, position: CGPoint(x: x, y: y))
                patchesIn.append(patchIn)
            }
        }
        return patchesIn
    }
    
    private func predict(patches: [PatchIn]) -> [PatchOut] {
        var outs: [PatchOut] = []
        
        for patch in patches {
            do {
                let res = try model.prediction(image: patch.buff)
                let out = PatchOut(buff: res.output1, position: patch.position)
                outs.append(out)
            } catch {
                print(error)
                continue
            }
        }
        return outs
    }
    
    private func render(patches: [PatchOut], size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        for patch in patches {
            let pos = patch.position
            guard let image = patch.buff.image(offset: 0, scale: 255) else {
                fatalError()
                continue
            }
            let rect = CGRect(x: pos.x * CGFloat(patchOutSize),
                              y: pos.y * CGFloat(patchOutSize),
                              width: CGFloat(patchOutSize),
                              height: CGFloat(patchOutSize))
            image.draw(in: rect)
        }
        
        let dst = UIGraphicsGetImageFromCurrentImageContext()
        return dst
    }
    
    public func convert(from src: UIImage) -> UIImage? {
        mesure("start Fast-SRCNN",0)
        let t = Date()
        
        let t0 = Date()
        mesure("resize", t0.timeIntervalSince(t))
        
        let t1 = Date()
        mesure("expand",t1.timeIntervalSince(t0))
        
        /////////////
        let patches = crop(src: src)
        
        let t2 = Date()
        mesure("crop",t2.timeIntervalSince(t1))
        
        /////////////
        let outPatches = predict(patches: patches)
        
        let t3 = Date()
        mesure("predict",t3.timeIntervalSince(t2))
        /////////////
        var size = src.size
        size.width *= 2
        size.height *= 2
        let res = render(patches: outPatches, size: size)
        
        let t4 = Date()
        mesure("render",t4.timeIntervalSince(t3))
        /////////////
        
        mesure("total",t4.timeIntervalSince(t))
        return res
    }
    private func mesure(_ msg: String, _ time: TimeInterval) {
        print(String(format: "\(msg):\t%.2f", time))
    }
}
