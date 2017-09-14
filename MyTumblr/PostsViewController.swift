//
//  PhotosViewController.swift
//  MyTumblr
//
//  Created by Kavita Gaitonde on 9/13/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit
import AFNetworking

class PostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var posts: [NSDictionary] = []
    var refreshControl : UIRefreshControl?
    var infiniteScrollActivityView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var postOffset = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Add UI refreshing on pull down
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        self.tableView.insertSubview(self.refreshControl!, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        infiniteScrollActivityView = InfiniteScrollActivityView(frame: frame)
        infiniteScrollActivityView!.isHidden = true
        self.tableView.addSubview(infiniteScrollActivityView!)
        
        var insets = self.tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight + 50
        self.tableView.contentInset = insets
        
        // Do any additional setup after loading the view.
        loadData(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData (_ offset : Int) {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(offset)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        print ("Loading data with offset \(offset)........")

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        let postsArray : [NSDictionary] = responseFieldDictionary["posts"] as! [NSDictionary]
                        let currCount = postsArray.count
                        
                        if(offset == 0) {
                            if (self.posts.count > 0) {
                                self.posts.replaceSubrange(0...currCount-1, with:postsArray)
                            } else {
                                self.posts = postsArray
                                self.postOffset=currCount
                            }
                        } else {
                            if(self.posts.count <= offset) { //load more data
                                self.posts+=postsArray
                                self.postOffset+=currCount
                            } else {
                                let start = offset
                                let end = start+currCount
                                self.posts.replaceSubrange(start...end, with: responseFieldDictionary["posts"] as! [NSDictionary])
                            }
                        }
                        self.isMoreDataLoading = false
                        print ("Updated offset \(self.postOffset)........")
                        print(self.posts)
                        
                        // Stop the loading indicator
                        self.infiniteScrollActivityView!.stopAnimating()
                        
                        self.tableView.reloadData()
                        
                        self.refreshControl!.endRefreshing()
                    }
                }
        });
        task.resume()
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let post = self.posts[section]
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0).cgColor //UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")! as URL)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the name here
        let label = UILabel(frame: CGRect(x: 50, y: 5, width: 200, height: 25))
        label.text = post["blog_name"] as? String
        label.font = label.font.withSize(15)
        headerView.addSubview(label)
        
        // Add a UILabel for the date here
        let timestamp = post["timestamp"] as! Double
        let date = NSDate(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        let timeZone = TimeZone.autoupdatingCurrent.identifier as String
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        let label1 = UILabel(frame: CGRect(x: 50, y: 25, width: 200, height: 20))
        label1.text = dateFormatter.string(from: date as Date)
        label1.font = label1.font.withSize(10)
        headerView.addSubview(label1)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let post = self.posts[section]
        return post["blog_name"] as? String
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as! PostsTableViewCell
        let post = self.posts[indexPath.section]
        let photos = post["photos"] as! NSArray
        let firstPhoto = photos[0] as? NSDictionary
        let photoDict = firstPhoto?["original_size"] as? NSDictionary
        if let photoPath = photoDict?["url"] as? String {
            let posterUrl = NSURL(string: photoPath)
            cell.postsImageView.setImageWith(posterUrl! as URL)
        }
        return cell
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(0)
    }
    
    //Scrollview Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            //actual hieght of the table filled in with content - height of 1 page of content
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                print("Loading more data.......offset = \(self.postOffset)")
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                infiniteScrollActivityView?.frame = frame
                infiniteScrollActivityView!.startAnimating()
                
                loadData(self.postOffset)
            }
            
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showPostDetailsSegue" {
            let cell = sender as! PostsTableViewCell
            if let indexPath = self.tableView.indexPath(for: cell) {
                let detailsController = segue.destination as! PostDetailsViewController
                detailsController.post = self.posts[indexPath.row]
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    

}
