//
//  DetailsViewController.swift
//  Flicks
//
//  Created by John Henning on 1/18/16.
//  Copyright © 2016 John Henning. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        titleLabel.text = title
        overviewLabel.text = overview
        
        let posterPath = movie["poster_path"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        
        let imageURL = NSURL(string: baseURL + posterPath)
        
        
        posterView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (request, response, image) in
            self.posterView.image = image
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.posterView.alpha = 1.0
                }, completion: nil)
            }, failure: nil)

        
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
