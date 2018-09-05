//
//  MangaViewController.swift
//  SuperResolutionKit_Example
//
//  Created by Kentaro Matsumae on 2018/08/18.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import SuperResolutionKit

class MangaViewController: UIViewController {
    
    var images: [UIImage] = []
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private var pageVCs: [UIViewController] = []
    private var currentPid: String = ""
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        
        self.pageVCs = images.map {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "View") as! ViewController
            vc.image = $0
            return vc
        }
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([pageVCs[0]], direction: .forward, animated: true, completion: nil)
        
        view.insertSubview(pageViewController.view, at: 0)
        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)
    }
    
    var currentViewController: ViewController {
        return pageViewController.viewControllers?.first as! ViewController
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetDidTap(_ sender: Any) {
        currentViewController.reset(sender)
    }
    
    @IBAction func action1DidTap(_ sender: Any) {
        process { (completion) in
            currentViewController.imageView.setSRImage(image: currentViewController.image!, completion: completion)
        }
    }
    
    @IBAction func action1CDidTap(_ sender: Any) {
        process {[weak self] (completion) in
            let imageView = self!.currentViewController.imageView
            let src = self!.currentViewController.image!
            imageView.image = src
            
            DispatchQueue.global().async {
                let converter = SRCNNConverter(modelName: "SRCNN-photo")
                if let output = converter.convert(from: src) {
                    DispatchQueue.main.async {
                        imageView.image = output
                        imageView.layer.add(CATransition(), forKey: nil)
                        completion()
                    }
                }
            }
        }
    }

    @IBAction func action2DidTap(_ sender: Any) {
        process { (completion) in
            currentViewController.imageView.setFSRImage(image: currentViewController.image!, completion: completion)
        }
    }
    
    private func process(execute:(_: @escaping ()->Void)->Void) {
        let pid = UUID().uuidString
        currentPid = pid
        
        loadingView.isHidden = false
        loadingIndicator.isHidden = false
        loadingLabel.text = "Prosessing..."
        let start = Date()
        execute() { [weak self] in
            let elapsed = Date().timeIntervalSince(start)
            self?.loadingIndicator.isHidden = true
            self?.loadingLabel.text = String(format: "Done: %.2f sec", elapsed)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                if self?.currentPid == pid {
                    self?.loadingView.isHidden = true
                }
            })
        }
    }
}

extension MangaViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let idx = pageVCs.index(of: viewController), 0 <= idx - 1 {
            return pageVCs[idx - 1]
        } else {
            return nil
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let idx = pageVCs.index(of: viewController), idx + 1 < pageVCs.count {
            return pageVCs[idx + 1]
        } else {
            return nil
        }
    }
    
    /*
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    }
    */
}

extension MangaViewController: UIPageViewControllerDelegate {
    /*
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }

    public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
    }
    
    public func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        
    }
    
    public func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        
    }
    */

}
