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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let photos = post["photos"] as! NSArray
        let firstPhoto = photos[0] as? NSDictionary
        let photoDict = firstPhoto?["original_size"] as? NSDictionary
        if let photoPath = photoDict?["url"] as? String {
            let postUrl = NSURL(string: photoPath)
            imageView.setImageWith(postUrl! as URL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
