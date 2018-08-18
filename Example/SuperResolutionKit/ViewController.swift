//
//  ViewController.swift
//  SuperResolutionKit
//
//  Created by kenmaz on 07/11/2018.
//  Copyright (c) 2018 kenmaz. All rights reserved.
//

import UIKit
import SuperResolutionKit

class ViewController: UIViewController {

    var image: UIImage? = nil
    let imageView = UIImageView(image: nil)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
        reset(self)
        imageView.sizeToFit()
        imageView.frame.origin.y = 100

        if let size = image?.size {
            let ratio = view.frame.size.width / size.width
            scrollView.minimumZoomScale = ratio
            scrollView.setZoomScale(ratio, animated: false)
        }
    }

    func runSR(_ sender: Any) {
        imageView.setSRImage(image: image!)
    }
    
    func runFSR(_ sender: Any) {
        imageView.setFSRImage(image: image!)
    }

    func reset(_ sender: Any) {
        imageView.image = image
        imageView.sizeToFit()
    }

    @IBAction func doubleTap(_ sender: Any) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

