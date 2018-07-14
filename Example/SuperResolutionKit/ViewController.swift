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

    private let imageView = UIImageView(image: nil)
    @IBOutlet weak var scrollView: UIScrollView!
    
    let input = UIImage(named: "sample.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
        reset(self)
    }

    @IBAction func runSR(_ sender: Any) {
        imageView.setSRImage(image: input)
    }
    
    @IBAction func runFSR(_ sender: Any) {
        imageView.setFSRImage(image: input)
    }

    @IBAction func reset(_ sender: Any) {
        imageView.image = input
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

