//
//  ViewController.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var flightNo: UITextField!
    @IBOutlet weak var searchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        lastName.delegate = self
        flightNo.delegate = self
        
        // Enable the Search button only if the text field has a valid Meal name.
        checkValidQuery()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        searchButton.enabled = false
    }
    
    func checkValidQuery() {
        // Disable the Search button if the text field is empty.
        let text = lastName.text ?? ""
        searchButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidQuery()
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let searchResultViewController = segue.destinationViewController as! ServiceTableViewController
        searchResultViewController.queries = "name=\(lastName.text!)"
    }

}

