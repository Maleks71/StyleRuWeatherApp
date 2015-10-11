//
//  SettingsViewController.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 11.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import UIKit

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

class SettingsViewController: UIViewController {

    @IBOutlet var cityField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let memoryCity = defaults.stringForKey("StyleRuCity") {
            cityField.text = memoryCity
        } else {
            cityField.placeholder = "Print city here"
        }
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(cityField.text!, forKey: "StyleRuCity")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func editingChanged(sender: UITextField) {
        if sender.text?.trim().characters.count > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
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
