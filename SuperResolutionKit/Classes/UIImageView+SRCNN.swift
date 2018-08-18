//
//  UIImageView+SRCNN.swift
//  SRCNNKit
//
//  Copyright (c) 2018 DeNA Co., Ltd. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func setSRImage(image src: UIImage) {
        setSRImage(image: src, completion: {})
    }
    
    public func setSRImage(image src: UIImage, completion: @escaping (() -> Void)) {
        self.image = src
        DispatchQueue.global().async { [weak self] in
            if let output = SRCNNConverter.shared.convert(from: src) {
                DispatchQueue.main.async {
                    self?.image = output
                    self?.layer.add(CATransition(), forKey: nil)
                    completion()
                }
            }
        }
    }
    
    public func setFSRImage(image src: UIImage) {
        setFSRImage(image: src, completion: {})
    }
    
    public func setFSRImage(image src: UIImage, completion: @escaping (() -> Void)) {
        self.image = src
        DispatchQueue.global().async { [weak self] in
            if let output = FSRCNNConverter.shared.convert(from: src) {
                DispatchQueue.main.async {
                    self?.image = output
                    self?.layer.add(CATransition(), forKey: nil)
                    completion()
                }
            }
        }
    }
}
