//
//  ViewController.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 07.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

func set_task(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

let weatherData = WeatherData()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params1 = [
            "q" : "Moscow",
            "mode" : "json",
            "units" : "metric",
            "APPID" : "d1c9745179e1566578438f0f6fd39399"
        ]
        
        let params2 = [
                "q" : "Moscow",
             "mode" : "json",
            "units" : "metric",
              "cnt" : "6",
            "APPID" : "d1c9745179e1566578438f0f6fd39399"
        ]
        
        // Get now weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params1).responseJSON { response in
            
            if let js = response.result.value {
                
                let data = JSON(js)
                print("/////1st: \(data)")
                
                weatherData.nowTemp = data["main"]["temp"].double ?? 999.0
                weatherData.nowWeather = data["weather"][0]["main"].string ?? "-"
            }
        }
        
        // Get next weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: params2)
            .responseJSON { response in
                
            if let js = response.result.value {
                
                let data = JSON(js)
                print("/////2nd: \(data)")
                
                weatherData.todayTemps[0] = data["list"][0]["temp"]["night"].double ?? 999.0
                weatherData.todayTemps[1] = data["list"][0]["temp"]["morn"].double ?? 999.0
                weatherData.todayTemps[2] = data["list"][0]["temp"]["day"].double ?? 999.0
                weatherData.todayTemps[3] = data["list"][0]["temp"]["eve"].double ?? 999.0
                
                for i in 0..<6 {
                    
                    /*var nextTemps = [Int]()
                    
                    if let night = data["list"][i]["night"].int {
                        nextTemps.append(night)
                    }
                    if let morn = data["list"][i]["morn"].int {
                        nextTemps.append(morn)
                    }
                    if let day = data["list"][i]["day"].int {
                        nextTemps.append(day)
                    }
                    if let eve = data["list"][i]["eve"].int {
                        nextTemps.append(eve)
                    }
                    
                    weatherData.nextTemp[i] = nextTemps.reduce(0, combine: +) / nextTemps.count */
                    
                    let summ =
                        data["list"][i]["temp"]["night"].double! +
                        data["list"][i]["temp"]["morn"].double! +
                        data["list"][i]["temp"]["day"].double! +
                        data["list"][i]["temp"]["eve"].double!
                    
                    weatherData.nextTemp[i] = summ / 4.0
                    
                    weatherData.nextWeather[i] = data["list"][i]["weather"][0]["main"].string ?? "-"
                }
                
                /*let count = data["cnt"].int ?? 0
                print(count)
                for i in 0..<count {
                    
                    if let temp = data["list"][i]["main"]["temp"].int {
                        print("\(i). \(temp)")
                    }
                }*/
                
            }
        }
        
        set_task(3.0) {
            
            print("\n//////////")
            print("nowTemp = \(weatherData.nowTemp)")
            print("nowWeather = \(weatherData.nowWeather)\n")
            
            print("todayTemps = \(weatherData.todayTemps)")
            print("nextTemp = \(weatherData.nextTemp)")
            print("nextWeather = \(weatherData.nextWeather)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

