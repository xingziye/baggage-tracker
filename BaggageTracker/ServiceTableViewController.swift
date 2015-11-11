//
//  ServiceTableViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/27/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class ServiceTableViewController: UITableViewController {
    // MARK: Properties
    var baggages = [Baggage]()
    var service: Service!
    var newBag: Baggage?
    var queries: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        service = Service()
        service.getInfo(queries!) {
            (response) in
            for item in response {
                let from = item["departure"] as! String
                let to = item["destination"] as! String
                //let flight = item["flight"] as! String
                let name = item["name"] as! String
                let port1 = Airport(name: from, location: from)
                let port2 = Airport(name: to, location: to)
                let bag = Baggage(name: name, departure: port1, destination: port2)
                self.baggages += [bag]
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baggages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "BaggageTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BaggageTableViewCell
        
        // Fetches the appropriate baggage for the data source layout.
        let bag = baggages[indexPath.row]
        
        cell.bagNameLabel.text = bag.name
        cell.bagInfoLabel.text = bag.departure.name + "✈️" + bag.destination.name
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            newBag = baggages[indexPath.row]
        }
    }

}
