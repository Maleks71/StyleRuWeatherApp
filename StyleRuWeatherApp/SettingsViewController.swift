//
//  SettingsViewController.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 11.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import UIKit
import CoreLocation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

class SettingsViewController: UITableViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
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

    @IBAction func useCurrentLocationButton(sender: AnyObject) {
        print("touch")
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("progress")
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        print(coord.latitude)
        print(coord.longitude)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
                case CLAuthorizationStatus.Restricted: break
                case CLAuthorizationStatus.Denied: break
                case CLAuthorizationStatus.NotDetermined: break
                default: shouldIAllow = true
            }
        
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        
            if (shouldIAllow == true) {
                locationManager.startUpdatingLocation()
            }
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(cityField.text!.capitalizedString, forKey: "StyleRuCity")
        
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
