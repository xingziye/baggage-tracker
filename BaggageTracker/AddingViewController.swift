//
//  AddingViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 11/18/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class AddingViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var airportList = ["LAN", "DTW", "ORD", "CTU", "LAX", "BWI", "VEN", "IRQ", "MSU", "MLL", "ETY", "CWY"]
    @IBOutlet weak var origin: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var flightTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var beingEditing: UITextField?
    var newBaggages = [Baggage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        origin.delegate = self
        destination.delegate = self
        flightTextField.delegate = self

        pickerView.hidden = true
        checkValidEditing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return airportList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return airportList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (beingEditing == origin) {
            origin.text = airportList[row]
        } else {
            destination.text = airportList[row]
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField == origin || textField == destination) {
            nameTextField.resignFirstResponder()
            flightTextField.resignFirstResponder()
            beingEditing = textField
            pickerView.hidden = false
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        doneButton.enabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidEditing()
    }
    
    func checkValidEditing() {
        // Disable the Search button if the text field is empty.
        let nameText = nameTextField.text ?? ""
        let originText = origin.text ?? ""
        let destinationText = destination.text ?? ""
        let flightText = flightTextField.text ?? ""
        if nameText.isEmpty || originText.isEmpty || destinationText.isEmpty || flightText.isEmpty {
            doneButton.enabled = false
        } else {
            doneButton.enabled = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func addDone(sender: AnyObject) {
        
        self.newBaggages.removeAll()
        let queries = "name=\(nameTextField.text!)&flight=\(flightTextField.text!)&origin=\(origin.text!)&destination=\(destination.text!)"
        let service = Service()
        service.getInfo(queries) {
            (response) in
            if response.count < 1 {
                let from = Airport(code: self.origin.text!)
                let to = Airport(code: self.destination.text!)
                let flight = self.flightTextField.text!
                let newBag = Baggage(name: self.nameTextField.text!, origin: from, destination: to, flight: flight)
                if self.imageView.image != UIImage(named: "Select") {
                    let imageData = UIImagePNGRepresentation(self.imageView.image!)
                    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let imageName = NSUUID().UUIDString
                    let imagePath = paths.stringByAppendingPathComponent(imageName)
                    imageData?.writeToFile(imagePath, atomically: true)
                    newBag.imagePath = imagePath
                }
                self.newBaggages += [newBag]
                self.performSegueWithIdentifier("unwindToBaggageList", sender: self)
            } else {
                for item in response {
                    let from = item["departure"] as! String
                    let to = item["destination"] as! String
                    let flight = item["flight"] as! String
                    let name = item["name"] as! String
                    let id = item["tag_id"] as! String
                    let status = item["bag_status"] as! String
                    let port1 = Airport(code: from)
                    let port2 = Airport(code: to)
                    let bag = Baggage(name: name, origin: port1, destination: port2, flight: flight)
                    bag.id = id
                    bag.flight = flight
                    bag.status = status
                    if self.imageView.image != UIImage(named: "Select") {
                        let imageData = UIImagePNGRepresentation(self.imageView.image!)
                        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                        let imageName = NSUUID().UUIDString
                        let imagePath = paths.stringByAppendingPathComponent(imageName)
                        imageData?.writeToFile(imagePath, atomically: true)
                        bag.imagePath = imagePath
                    }
                    self.newBaggages += [bag]
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("showMultipleResults", sender: self)
                }
            }
        }
    }
    
    @IBAction func pickDone(sender: AnyObject) {
        pickerView.hidden = true
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation

    @IBAction func cancle(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToBaggageList" {
            let baggageTableViewController = segue.destinationViewController as! BaggageTableViewController
            baggageTableViewController.baggages += newBaggages
        } else if segue.identifier == "showMultipleResults" {
            let serviceTalbeViewController = segue.destinationViewController as! ServiceTableViewController
            serviceTalbeViewController.baggages += newBaggages
        }
        
    }
}
