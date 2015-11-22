//
//  DetailsViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 11/21/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flightLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var bag: Baggage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        self.navigationController? .setNavigationBarHidden(false, animated:true)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setTitle("TITLE", forState: UIControlState.Normal)
        backButton.sizeToFit()
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonItem
        */
        
        if let bag = bag {
            nameLabel.text = bag.name
            flightLabel.text = bag.flight
            originLabel.text = bag.origin.code
            destinationLabel.text = bag.destination.code
            if let status = bag.status {
                statusLabel.text = status
            } else {
                statusLabel.text = "Unchecked"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStatus(bag: Baggage) {
        let queries = "name=\(bag.name)&flight=\(bag.flight)&origin=\(bag.origin.code)&destination=\(bag.destination.code)"
        let service = Service()
        service.getInfo(queries) {
            (response) in
            if response.count >= 1 {
                for item in response {
                    let id = item["tag_id"] as! String
                    if id == bag.id! {
                        let status = (item["bag_status"] as! String)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.statusLabel.text = status
                        }
                    }
                }
            }
        }
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
