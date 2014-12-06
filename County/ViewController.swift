//
//  ViewController.swift
//  County
//
//  Created by Elad Ben-Israel on 12/6/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, CountyClientDelegate {

    let county = CountyClient(baseURL: NSURL(string: "http://county.snappers.co")!, group: "mygroup")
    var counters = [String:UInt]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        county.delegate = self
        county.connect()
    }

    func countyClient(client: CountyClient, didUpdateCounters counters: [String : UInt]) {
        for (key, value) in counters {
            self.counters[key] = value
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.counters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("counter", forIndexPath: indexPath) as UITableViewCell
        let key = self.counters.keys.array[indexPath.row]
        let value = self.counters[key]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = "\(value!)"
        return cell
    }

    @IBAction func incrementA() {
        self.county.incrementKey("A", byValue: 1)
    }

    @IBAction func incrementB() {
        self.county.incrementKey("B", byValue: 1)
    }

    @IBAction func incrementC() {
        self.county.incrementKey("C", byValue: 1)
    }

    @IBAction func incrementD() {
        self.county.incrementKey("D", byValue: 10)
    }
}

