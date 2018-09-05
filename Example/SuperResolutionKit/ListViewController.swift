//
//  ListViewController.swift
//  SuperResolutionKit_Example
//
//  Created by kenmaz on 2018/08/31.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    enum MangaTitle: String {
        case blackJack = "Black Jack"
        case penki = "Penki"
        case photo = "Photo"
    }
    
    private let titles: [MangaTitle] = [.blackJack, .penki, .photo]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        let images: [UIImage]
        switch title {
        case .blackJack:
            images = [#imageLiteral(resourceName: "01bj-page7.jpg"),#imageLiteral(resourceName: "01bj-page11.jpg"),#imageLiteral(resourceName: "01bj-page10.jpg"),#imageLiteral(resourceName: "01bj-page12.jpg"),#imageLiteral(resourceName: "01bj-page13.jpg"),#imageLiteral(resourceName: "01bj-page14.jpg"),#imageLiteral(resourceName: "01bj-page9.jpg"),#imageLiteral(resourceName: "01bj-page8.jpg"),#imageLiteral(resourceName: "01bj-page15.jpg")]
        case .penki:
            images = [#imageLiteral(resourceName: "p10.png"),#imageLiteral(resourceName: "p9.png"),#imageLiteral(resourceName: "p8.png"),#imageLiteral(resourceName: "p3.png"),#imageLiteral(resourceName: "p2.png"),#imageLiteral(resourceName: "p1.png"),#imageLiteral(resourceName: "p5.png"),#imageLiteral(resourceName: "p4.png"),#imageLiteral(resourceName: "p6.png"),#imageLiteral(resourceName: "p7.png")]
        case .photo:
            images = [#imageLiteral(resourceName: "img_002_SRF_2_HR.png"),#imageLiteral(resourceName: "img_002_SRF_8_HR.png"),#imageLiteral(resourceName: "img_003_SRF_8_HR.png"),#imageLiteral(resourceName: "img_012_SRF_2_HR.png"),#imageLiteral(resourceName: "img_012_SRF_8_HR.png"),#imageLiteral(resourceName: "img_013_SRF_2_HR.png"),#imageLiteral(resourceName: "img_013_SRF_8_HR.png")]
            
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "MangaViewController") as! MangaViewController
        vc.images = images
        present(vc, animated: true, completion: nil)
    }
    
}
