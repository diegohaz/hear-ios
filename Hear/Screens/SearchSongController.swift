//
//  SearchSongController.swift
//  Hear
//
//  Created by Juliana Zilberberg on 10/20/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import UIKit
import Bolts


class SearchSongController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var songs = [Song]()
    
    @IBOutlet weak var tableCell: UITableView!
    @IBOutlet weak var searchBar: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view = tableview.registerNib(UINib(nibName: "SearchSongView.xib", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MyCell");
//        view = UINib(nibName: "SearchSongView", bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as? UIView
//        searchBar.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
    }
    
    
//    func searchDidReturn() {
//    ParseAPI.searchSong("texto").continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
//            self.songs = task.result as! [Song]
//        
//            return task
//        })
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = songs[indexPath.row].title
        
        return cell
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        ParseAPI.searchSong("texto").continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            self.songs = task.result as! [Song]
            
            return task
        })
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
        
    }
}



