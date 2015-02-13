//
//  LeftViewController.swift
//  SchemaAppKTH
//
//  Created by Kj Drougge on 2015-01-24.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit

protocol LeftViewControllerDelegate{
    func scheduleSelected(schedule: String)
}

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var delegate: LeftViewControllerDelegate?
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var data: [String] = []
    var filteredData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        
        
        let path = NSBundle.mainBundle().pathForResource("schedules", ofType: "plist")
        let arr = NSArray(contentsOfFile: path!)
        
        data = arr as [String]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filteredContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredData = data.filter({
            (data: String) -> Bool in
            
            let stringMatch = data.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            
            return stringMatch != nil
        })
    }
    
    
    // MARK: Seach Display Controller Delegate
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filteredContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        filteredContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == searchDisplayController!.searchResultsTableView {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = resultTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        
        var dataStr: String!
        var hue: CGFloat!
        
        if tableView == searchDisplayController!.searchResultsTableView {
            dataStr = filteredData[indexPath.row]
            hue = CGFloat(indexPath.row)/CGFloat(filteredData.count)
        } else {
            dataStr = data[indexPath.row]
            hue = CGFloat(indexPath.row)/CGFloat(data.count)
        }
        
        
        cell.backgroundColor = UIColor(hue: hue, saturation: 0.6, brightness:1.0, alpha: 0.7)
        
        //cell.backgroundColor = UIColor.greenColor()
        cell.textLabel?.text = dataStr
        
        return cell
    }
    
    // Mark: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedSchedule = data[indexPath.row]
        delegate?.scheduleSelected(selectedSchedule)
    }
    
    
}
