//
//  PostDetailsViewController.swift
//  MyTumblr
//
//  Created by Kavita Gaitonde on 9/13/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController {

    var post : NSDictionary = [:]
    var imageUrl : String?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let photos = post["photos"] as! NSArray
        let firstPhoto = photos[0] as? NSDictionary
        let photoDict = firstPhoto?["original_size"] as? NSDictionary
        if let iUrl = photoDict?["url"] as? String {
            self.imageUrl = iUrl
            let postUrl = NSURL(string: self.imageUrl!)
            imageView.setImageWith(postUrl! as URL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        if (self.imageUrl != nil) {
            performSegue(withIdentifier: "showZoomableImageView", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showZoomableImageView" {
            if (self.imageUrl != nil) {
                let zoomController = segue.destination as! ZoomableImageViewController
                zoomController.imageUrl = self.imageUrl!
            }
        }
    }


}
