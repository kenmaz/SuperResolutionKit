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

    @IBOutlet weak var imageView: UIImageView!
    
    let input = UIImage(named: "sample.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reset(self)
    }

    @IBAction func runSR(_ sender: Any) {
        imageView.setSRImage(image: input)
    }
    
    @IBAction func reset(_ sender: Any) {
        imageView.image = input
    }
}

