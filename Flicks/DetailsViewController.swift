//
//  DetailsViewController.swift
//  Flicks
//
//  Created by John Henning on 1/18/16.
//  Copyright © 2016 John Henning. All rights reserved.
//
// swiftlint:disable variable_name
// swiftlint:disable trailing_whitespace
// swiftlint:disable line_length

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.size.height )
        
        view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.80)
        
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        
        titleLabel.text = title
        overviewLabel.text = overview
        
        overviewLabel.sizeToFit()
        
        if movie["poster_path"]!.isKindOfClass(NSNull) == false {
            let posterPath = movie["poster_path"] as? String
        
            let smallBaseURL = "http://image.tmdb.org/t/p/w342/"
            let largeBaseURL = "http://image.tmdb.org/t/p/original"
        
            let smallImageURL = NSURL(string: smallBaseURL + posterPath!)
            let largeImageURL = NSURL(string: largeBaseURL + posterPath!)
        
        
            let smallImageRequest = NSURLRequest(URL: smallImageURL!)
            let largeImageRequest = NSURLRequest(URL: largeImageURL!)
        
            posterView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterView.alpha = 0.0
                    self.posterView.image = smallImage
                
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                        self.posterView.alpha = 1.0
                    
                    }, completion: { (success) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterView.image = largeImage
                                
                            },
                            failure: { (request, response, error) -> Void in
                            
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                                
                                
                        })
                    })
                },
                failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
            })
        
        } else {
            let imageURL = NSURL(string: "http://i.imgur.com/R7mqXKL.png")
            posterView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (request, response, image) in
                self.posterView.image = image
                }, failure: nil)
            
        }
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
