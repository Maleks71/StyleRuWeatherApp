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
                print("\n/////1st: \(data)")
                
                if let nowTemp = data["main"]["temp"].double {
                    weatherData.nowTemp = Int( round(nowTemp) )
                }
                
                if let nowWindSpeed = data["wind"]["speed"].int {
                    
                    let convert = round( Double(nowWindSpeed) * 3.6 )
                    weatherData.nowWindSpeed = Int(convert)
                }
                
                if let nowPressure = data["main"]["pressure"].int {
                    weatherData.nowPressure = nowPressure
                }
                
                weatherData.nowWeather = data["weather"][0]["main"].string ?? "?"
            }
        }
        
        // Get next weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: params2)
            .responseJSON { response in
                
            if let js = response.result.value {
                
                let data = JSON(js)
                print("\n/////2nd: \(data)")
                
                func convertToRoundInt(d: Double?) -> Int {
                    return Int( round(d ?? 777.0) )
                }
                
                weatherData.todayTemps[0] = convertToRoundInt(data["list"][0]["temp"]["night"].double)
                weatherData.todayTemps[1] = convertToRoundInt(data["list"][0]["temp"]["morn"].double)
                weatherData.todayTemps[2] = convertToRoundInt(data["list"][0]["temp"]["day"].double)
                weatherData.todayTemps[3] = convertToRoundInt(data["list"][0]["temp"]["eve"].double)
                
                let count = data["cnt"].int ?? 0
                for i in 0..<count {
                    
                    var nextTemp = [Double]()
                    
                    if let night = data["list"][i]["night"].double {
                        nextTemp.append(night)
                    }
                    
                    if let morn = data["list"][i]["morn"].double {
                        nextTemp.append(morn)
                    }
                    
                    if let day = data["list"][i]["day"].double {
                        nextTemp.append(day)
                    }
                    
                    if let eve = data["list"][i]["eve"].double {
                        nextTemp.append(eve)
                    }
                    
                    if nextTemp.count != 0 {
                        let summ = round( nextTemp.reduce(0, combine: +) / Double(nextTemp.count) )
                        weatherData.nextTemp[i] = Int(summ)
                    }
                    
                    weatherData.nextWeather[i] = data["list"][i]["weather"][0]["main"].string ?? "?"
                }
            }
        }
        
        set_task(2.0) {
            
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

