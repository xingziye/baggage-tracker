//
//  BaggageTableViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class BaggageTableViewController: UITableViewController, UINavigationControllerDelegate {
    // MARK: Properties
    var baggages = [Baggage]()
    var updatedBags = [Baggage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let savedBags = loadBags() {
            baggages += savedBags
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
        if let status = bag.status {
            cell.bagInfoLabel.text = status
        } else {
            cell.bagInfoLabel.text = "Unchecked"
        }
        if let imagePath = bag.imagePath {
            cell.bagImage.image = UIImage(contentsOfFile: imagePath)
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            baggages.removeAtIndex(indexPath.row)
            saveBags()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updatedBags.removeAll()
        let bag = baggages[indexPath.row]
        let query = "name=\(bag.name)&flight=\(bag.flight)&origin=\(bag.origin.code)&destination=\(bag.destination.code)"
        let service = Service()
        service.getInfo(query) {
            (response) in
            print(response)
            if response.count >= 1 {
                if let _ = bag.id {
                    for item in response {
                        let tag_id = item["tag_id"] as! String
                        if bag.id == tag_id {
                            bag.status = (item["bag_status"] as! String)
                            self.updatedBags.append(bag)
                            self.baggages[indexPath.row] = bag
                            dispatch_async(dispatch_get_main_queue()) {
                                self.baggages[indexPath.row] = bag
                                self.saveBags()
                                self.tableView.reloadData()
                                self.performSegueWithIdentifier("showDetails", sender: self)
                            }
                            break
                        }
                    }
                } else {
                    self.baggages.removeAtIndex(indexPath.row)
                    self.saveBags()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    //self.tableView.reloadData()
                    
                    for item in response {
                        let id = item["tag_id"] as! String
                        let status = item["bag_status"] as! String
                        let newBag = Baggage(bag: bag)
                        newBag.id = id
                        newBag.status = status
                        self.updatedBags.append(newBag)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showResults", sender: self)
                    }
                }
            } else {
                self.updatedBags.append(bag)
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("showDetails", sender: self)
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetails" {
            let detailsViewController = segue.destinationViewController as! DetailsViewController
            detailsViewController.bag = updatedBags[0]
            //detailsViewController.updateStatus(bag)
        } else if segue.identifier == "showResults" {
            let serviceTableViewController = segue.destinationViewController as! ServiceTableViewController
            serviceTableViewController.baggages += updatedBags
        }
    }

    @IBAction func unwindToBaggageList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ServiceTableViewController, bag = sourceViewController.newBag {
            // Add a new baggage.
            let newIndexPath = NSIndexPath(forRow: baggages.count, inSection: 0)
            baggages.append(bag)
            saveBags()
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
        }
        if let _ = sender.sourceViewController as? AddingViewController {
            saveBags()
            tableView.reloadData()
        }
    }
    
    // MARK: NSCoding
    func saveBags() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(baggages, toFile: Baggage.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Saving Fails")
        }
    }
    
    func loadBags() -> [Baggage]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Baggage.ArchiveURL.path!) as? [Baggage]
    }

}
