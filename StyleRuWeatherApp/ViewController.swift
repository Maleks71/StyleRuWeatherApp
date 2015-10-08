//
//  ViewController.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 07.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = ["q" : "Moscow"]
        
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params)
            .responseJSON { response in
                //print("1. \(response.request)\n\n")  // original URL request
                //print("2. \(response.response)\n\n") // URL response
                //print("3. \(response.data)\n\n")     // server data
                print("4. \(response.result)\n\n")   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)\n\n")
                    
                    let data = JSON as! [String : AnyObject]
                    let name = data["name"]
                    print("data: \(name)")
                }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

