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

class ViewController: UIViewController {
    
    @IBOutlet var outNowTemp: UILabel!
    @IBOutlet var outNowWeather: UILabel!
    @IBOutlet var outNowWindSpeed: UILabel!
    @IBOutlet var outNowPressure: UILabel!
    
    @IBOutlet var outTodayTemps: [UILabel]!

    @IBOutlet var outNextTempsDay: [UILabel]!
    @IBOutlet var outNextTempsNight: [UILabel]!

    var currentCity = "Moscow"
    let weatherData = WeatherData()
    
    @IBAction func updateButton(sender: AnyObject) {
        self.updateCurrentCity()
        self.getWeatherData()
    }
    
    func updateCurrentCity() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let memoryCity = defaults.stringForKey("StyleRuCity") {
            self.currentCity = memoryCity
        }
    }
    
    // Debug
    func set_task(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCurrentCity()
        self.getWeatherData()
    }
    
    // MARK: Get weather data
    func getWeatherData() {
        
        let params1 = [
            "q" : self.currentCity,
            "mode" : "json",
            "units" : "metric",
            "APPID" : "d1c9745179e1566578438f0f6fd39399"
        ]
        
        let params2 = [
            "q" : self.currentCity,
            "mode" : "json",
            "units" : "metric",
            "cnt" : "6",
            "APPID" : "d1c9745179e1566578438f0f6fd39399"
        ]
        
        // MARK: Get now weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params1).responseJSON { response in
            
            if let js = response.result.value {
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                let data = JSON(js)
                print("\n/////1st: \(data)") // Debug
                
                // Now temperature
                if let nowTemp = data["main"]["temp"].double {
                    self.weatherData.nowTemp = Int( round(nowTemp) )
                }
                
                // Now weather
                self.weatherData.nowWeather = data["weather"][0]["main"].string  ?? "—"
                
                // Now wind speed
                if let nowWindSpeed = data["wind"]["speed"].int {
                    let convert = round( Double(nowWindSpeed) * 3.6 )
                    self.weatherData.nowWindSpeed = Int(convert)
                }
                
                // Now pressure
                if let nowPressure = data["main"]["pressure"].int {
                    self.weatherData.nowPressure = nowPressure
                }
                
                self.setNowWeatherOutlets()
            } else {
                print("ERROR")
            }
        }
        
        // MARK: Get next weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: params2)
            .responseJSON { response in
                
                if let js = response.result.value {
                    
                    let data = JSON(js)
                    print("\n/////2nd: \(data)") // Debug
                    
                    func convertToRoundInt(d: Double?) -> Int {
                        return Int( round(d ?? 777.0) )
                    }
                    
                    // Today temperatures
                    self.weatherData.todayTemps[0] = convertToRoundInt(data["list"][0]["temp"]["night"].double)
                    self.weatherData.todayTemps[1] = convertToRoundInt(data["list"][0]["temp"]["morn"].double)
                    self.weatherData.todayTemps[2] = convertToRoundInt(data["list"][0]["temp"]["day"].double)
                    self.weatherData.todayTemps[3] = convertToRoundInt(data["list"][0]["temp"]["eve"].double)
                    
                    let count = data["cnt"].int ?? 0
                    for i in 0..<count {
                        
                        // Next day & night temperatures
                        self.weatherData.nextTemp[i].day = Int( round(data["list"][i]["temp"]["day"].double ?? 777.0) )
                        self.weatherData.nextTemp[i].night = Int( round(data["list"][i]["temp"]["night"].double ?? 777.0) )
                        
                        // Next days weather
                        self.weatherData.nextWeather[i] = data["list"][i]["weather"][0]["main"].string ?? "?"
                    }
                    
                    self.setNextWeatherOutlets()
                }
        }
        
        // Debug
        set_task(4.0) {
            
            print("\n//////////")
            print("nowTemp = \(self.weatherData.nowTemp)")
            print("nowWeather = \(self.weatherData.nowWeather)")
            print("nowWindSpeed = \(self.weatherData.nowWindSpeed)")
            print("nowPressure = \(self.weatherData.nowPressure)\n")
            
            print("todayTemps = \(self.weatherData.todayTemps)\n")
            print("nextTemp = \(self.weatherData.nextTemp)\n")
            print("nextWeather = \(self.weatherData.nextWeather)")
        }
    }
    
    func setNowWeatherOutlets() {
        
        self.navigationItem.title = self.currentCity
        
        self.outNowTemp.text = String(self.weatherData.nowTemp) + "°"
        self.outNowWeather.text = self.weatherData.nowWeather
        self.outNowWindSpeed.text = String(self.weatherData.nowWindSpeed) + " km/h"
        self.outNowPressure.text = String(self.weatherData.nowPressure) + " hPa"
    }
    
    func setNextWeatherOutlets() {
        
        for i in 0...3 {
            self.outTodayTemps[i].text = String(self.weatherData.todayTemps[i])
        }
        
        for i in 0...5 {
            self.outNextTempsDay[i].text = String(self.weatherData.nextTemp[i].day)  + "°"
            self.outNextTempsNight[i].text = String(self.weatherData.nextTemp[i].night)  + "°"
        }
    }
    
}

