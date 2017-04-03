//
//  PostViewController.swift
//  DojStagram
//
//  Created by Paul Binneboese on 3/31/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import CoreData

class PostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
    }
    
    var delegate: GalleryViewController?
    var post: GalleryPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = post?.image
        self.captionText.text = post?.caption
        self.locationText.text = post?.location
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        dateformatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateformatter.string(from: post!.createdAt)
        self.dateText.text = dateString

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
