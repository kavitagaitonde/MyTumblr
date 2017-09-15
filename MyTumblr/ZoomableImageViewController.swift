//
//  ZoomableImageViewController.swift
//  MyTumblr
//
//  Created by Kavita Gaitonde on 9/14/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class ZoomableImageViewController: UIViewController, UIScrollViewDelegate {

    var imageUrl : String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let postUrl = NSURL(string: imageUrl!)
        self.imageView.setImageWith(postUrl! as URL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
