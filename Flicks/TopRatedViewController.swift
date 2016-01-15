//
//  TopRatedViewController.swift
//  
//
//  Created by John Henning on 1/13/16.
//
//

import UIKit
import AFNetworking
import EZLoadingActivity

class TopRatedViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate,UISearchBarDelegate{
    
    
    var refreshControl: UIRefreshControl!
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorButton: UIButton!
    
    
    var movies: [NSDictionary]!
    var filteredResults: [NSDictionary]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self;
        collectionView.delegate = self;
        searchBar.delegate = self;
        
        
        
        
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        
        
        movieDatabaseAPICall();
    }
    
    override func viewDidAppear(animated: Bool) {
        filteredResults = movies
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int{
            
            
            
           
            if let filteredResults = filteredResults {
                return filteredResults.count
            }
            else {
                return 0
            }
            
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! CollectionMovieCell
        
            let movie = filteredResults[indexPath.row]
            
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterPath = movie["poster_path"] as! String
            
            let baseURL = "http://image.tmdb.org/t/p/w500"
            
            
            let imageURL = NSURL(string: baseURL + posterPath)
            
            cell.titleLabel.text = title
            cell.overviewtextView.text = overview
            cell.posterView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (request, response, image) in
                cell.posterView.image = image
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    cell.posterView.alpha = 1.0
                    }, completion: nil)
                }, failure: nil)
            
            
            
            print("row \(indexPath.row)");
            return cell;
        
       
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.movieDatabaseAPICall()
            self.refreshControl.endRefreshing()
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = searchText.isEmpty ? movies : movies.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.collectionView.reloadData()
    }
    
    
    
    func movieDatabaseAPICall () -> () {
        EZLoadingActivity.showWithDelay("Loading...", disableUI: true, seconds: 1.0)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            
                            EZLoadingActivity.hide()
                            
                            if self.movies == nil {
                                self.networkErrorView.hidden = false
                                self.collectionView.center.y += 30
                                
                            }
                            
                            self.filteredResults = self.movies
                            self.collectionView.reloadData()
                            
                            
                            
                    }
                    
                }
        });
        task.resume()
        
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    @IBAction func onNetworkErrorButtonClicked(sender: AnyObject) {
        networkErrorView.hidden = true
        collectionView.center.y -= 30
        movieDatabaseAPICall()
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

