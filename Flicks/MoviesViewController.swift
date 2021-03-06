//
//  MoviesViewController.swift
//  Flicks
//
//  Created by John Henning on 1/5/16.
//  Copyright © 2016 John Henning. All rights reserved.
//
// swiftlint:disable variable_name
// swiftlint:disable trailing_whitespace
// swiftlint:disable line_length
import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UICollectionViewDataSource,
    UICollectionViewDelegate, UISearchBarDelegate {
    var refreshControl: UIRefreshControl!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorButton: UIButton!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var filteredResults: [NSDictionary]?
    var searchActive: Bool = false
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.90)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        collectionView.insertSubview(refreshControl, atIndex: 0)
        EZLoadingActivity.show("Loading...", disableUI: true)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        movieDatabaseAPICall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 0.5
    }
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 1.0
    }
    
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            
        if let filteredResults = self.filteredResults {
            print(filteredResults.count)
            return filteredResults.count
        } else {
            return 0
        }
        
    }
    

    
    

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as? CollectionMovieCell
        
        
        let movie = filteredResults![indexPath.row]
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        
        if movie["poster_path"]!.isKindOfClass(NSNull) == false {
            
            
            
            let posterPath = movie["poster_path"] as? String
            
            
            let imageURL = NSURL(string: baseURL + posterPath!)
            
            
            cell!.posterView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (request, response, image) in
                cell!.posterView.image = image
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    cell!.posterView.alpha = 1.0
                    }, completion: nil)
                }, failure: nil)

        } else {
            let imageURL = NSURL(string: "http://i.imgur.com/R7mqXKL.png")
            
            cell!.posterView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (request, response, image) in
                cell!.posterView.image = image
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    cell!.posterView.alpha = 1.0
                    }, completion: nil)
                }, failure: nil)
        
        }
        
        print("row \(indexPath.row)")
        return cell!
    }
    
    func delay(delay: Double, closure:()->()) {
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
    
    func movieDatabaseAPICall() {
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in

                
                if let data = dataOrNil {
                    if let responseDictionary = try? NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary!["results"] as? [NSDictionary]
                            
                            EZLoadingActivity.hide()
                            
                            self.filteredResults = self.movies
                            print(self.filteredResults![17]["poster_path"]!)
                            
                            self.collectionView.reloadData()
                            
                    }
                    
                   
                }
            self.networkButtonRefresh(self.filteredResults)
        })
        task.resume()
    }
    
    func networkButtonRefresh(movies: [NSDictionary]!) {
        
        if movies != nil {
            print("all good")
            if self.networkErrorView.hidden == false {
                self.networkErrorView.hidden = true
                self.collectionView.center.y -= 30
            }
        } else {
            print("nil")
            EZLoadingActivity.hide()
            if self.networkErrorView.hidden {
                self.networkErrorView.hidden = false
                self.collectionView.center.y += 30
            }
            
        }
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredResults = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as? String)!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.collectionView.reloadData()
        
    }
    
    
    @IBAction func onNetworkErrorButtonClicked(sender: AnyObject) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        movieDatabaseAPICall()
        
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tap = UITapGestureRecognizer(target: self, action: "endEditing")
        view.addGestureRecognizer(tap)
        
    }
   
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tap)
    }
    
    
    func endEditing() {
        view.endEditing(true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let cell = sender as? UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell!)
        
            let movie = filteredResults![(indexPath?.row)!]
        
            let detailsViewController = segue.destinationViewController as? DetailsViewController
        
            detailsViewController!.movie = movie
        
    }
    

}
