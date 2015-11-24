//
//  DetailsViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 11/21/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit
import AVFoundation

class DetailsViewController: UIViewController, UINavigationControllerDelegate, BLEDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flightLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var bag: Baggage?
    var bleShield = BLE()
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let button = UIBarButtonItem(title: "Connect", style: .Plain, target: self, action: "BLEShieldScan")
        //let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //let barItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = button
        
        if let bag = bag {
            nameLabel.text = bag.name
            flightLabel.text = bag.flight
            originLabel.text = bag.origin.code
            destinationLabel.text = bag.destination.code
            if let status = bag.status {
                statusLabel.text = status
            } else {
                statusLabel.text = "Unchecked"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
        
        //bleShield.controlSetup()
        bleShield.delegate = self
    }
    
    func BLEShieldScan() {
        if let activePeripher = bleShield.activePeripheral {
            bleShield.disconnectFromPeripheral(activePeripher)
            return
        }
        if bleShield.startScanning(3.0) {
            print(bleShield.peripherals)
            //BLEShield.connectToPeripheral(BLEShield.peripherals[0])
        }
    }
    
    func bleDidUpdateState() {
        print("bleDidUpdateState")
        
    }
    
    func bleDidConnectToPeripheral() {
        print("bleDidConnectToPeripheral")
        self.navigationItem.rightBarButtonItem?.title = "Disconnect"
    }
    
    func bleDidDisconnectFromPeripheral() {
        print("bleDidDisconenctFromPeripheral")
        self.navigationItem.rightBarButtonItem?.title = "Connect"
    }
    
    func bleDidReceiveData(data: NSData?) {
        print("bleDidReceiveData")
        let s = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        NSLog("%@", s)
        
        if s == bag?.id {
            if let soundURL = NSBundle.mainBundle().URLForResource("5718", withExtension: "mp3") {
                do {
                    try audioPlayer = AVAudioPlayer(contentsOfURL: soundURL)
                    audioPlayer.play()
                } catch _ {
                    print("sound cannot be played")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
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
    }*/
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let activePeripher = bleShield.activePeripheral {
            bleShield.disconnectFromPeripheral(activePeripher)
        }
    }

}
