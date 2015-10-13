//
//  SettingsViewController.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 11.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

class SettingsViewController: UITableViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    var isOnce = false
    var locationManager: CLLocationManager!
    
    @IBOutlet var cityField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cityField.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let memoryCity = defaults.stringForKey("StyleRuCity") {
            cityField.text = memoryCity
        } else {
            cityField.placeholder = "Введите город"
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func useCurrentLocationButton(sender: AnyObject) {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print("manager")
        locationManager.stopUpdatingLocation()
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        // Get city name
        if self.isOnce == false {
            self.isOnce = true
            
            let params = [
                "lat" : String(coord.latitude),
                "lon" : String(coord.longitude),
                "mode" : "json",
                "units" : "metric",
                "APPID" : appID
            ]
            
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params).responseJSON { response in
                
                if let js = response.result.value {
                    
                    let data = JSON(js)
                    
                    if let city = data["name"].string {
                        self.cityField.text = city
                        self.saveButton.enabled = true
                        
                    } else {
                        
                        self.cityField.placeholder = "Город не найден"
                    }
                } else {
                    self.cityField.placeholder = "Нет интернет соединения"
                }
            }
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
