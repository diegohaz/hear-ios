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

      tableCell.registerNib(UINib(nibName: "MyCell.xib", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MyCell");

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = songs[indexPath.row].title
        
        return cell
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        ParseAPI.searchSong("texto").continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject! in
            
            self.songs = task.result ["title"] as! [Song]
            
            self.songs = task.result ["artist"] as! [Song]
            
            self.songs = task.result ["songs"] as! [Song]
            
            
            return task
        })
        
        
            dispatch_async(dispatch_get_main_queue())
            {
                self.tableCell.reloadData()
                self.searchBar.resignFirstResponder()
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
        
    }




