//
//  TweetHomeViewController.swift
//  TwitterClone
//
//  Created by Alex G on 06.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

import UIKit

class TweetHomeViewController: UIViewController, UITableViewDataSource {
    // MARK: Outlets
    @IBOutlet weak var tweetsTable: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // MARK: Private properties
    private var tweetsArray = [Tweet]()
    private var sortedTweetsArray: Array<Tweet>?

    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTable.backgroundColor = UIColor(white: 0.9, alpha: 1)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: "segmentedControlValueChanged", forControlEvents:UIControlEvents.ValueChanged)
    
        if let filePath = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") {
            var error: NSError?
            if let jsonData = NSData.dataWithContentsOfFile(filePath, options: nil, error: &error) {
                if let tweetsArray = Tweet.parseJSONDataIntoTweets(jsonData) {
                    self.tweetsArray.extend(tweetsArray)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableView Delegates Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL") as UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        let arrayToShow = segmentedControl.selectedSegmentIndex == 0 ? tweetsArray : sortedTweetsArray
        cell.textLabel?.text = arrayToShow?[indexPath.row].text
        cell.detailTextLabel?.text = arrayToShow?[indexPath.row].dateString()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count;
    }
    
    // MARK: Private Methods
    func segmentedControlValueChanged() {
        if (segmentedControl.selectedSegmentIndex == 1)  && (sortedTweetsArray == nil) {
            sortedTweetsArray = tweetsArray.sorted {$0.text < $1.text}
        }
        tweetsTable.reloadData()
    }

}
