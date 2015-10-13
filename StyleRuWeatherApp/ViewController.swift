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

let appID = "d1c9745179e1566578438f0f6fd39399"

class ViewController: UIViewController {
    
    var currentCity = "Moscow"
    let weatherData = WeatherData()
    
    @IBOutlet var outNowTemp: UILabel!
    @IBOutlet var outNowWeather: UILabel!
    @IBOutlet var outNowWindSpeed: UILabel!
    @IBOutlet var outNowPressure: UILabel!
    
    @IBOutlet var outTodayTemps: [UILabel]!

    @IBOutlet var outNextTempsDay: [UILabel]!
    @IBOutlet var outNextTempsNight: [UILabel]!
    @IBOutlet var outNextWeather: [UILabel]!
    @IBOutlet var outNextWeekDay: [UILabel]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCurrentCity()
        self.getWeatherData()
    }
    
    @IBAction func updateButton(sender: AnyObject) {
        self.updateCurrentCity()
        self.getWeatherData()
    }
    
    func updateCurrentCity() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let memoryCity = defaults.stringForKey("StyleRuCity") {
            self.currentCity = memoryCity
        } else {
            self.currentCity = "Moscow"
            defaults.setObject("Moscow", forKey: "StyleRuCity")
        }
    }
    
    func getDayNameUnix(unixTime: Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: Get weather data
    func getWeatherData() {
        
        let params1 = [
            "q" : self.currentCity,
            "mode" : "json",
            "units" : "metric",
            "APPID" : appID
        ]
        
        let params2 = [
            "q" : self.currentCity,
            "mode" : "json",
            "units" : "metric",
            "cnt" : "6",
            "APPID" : appID
        ]
        
        // MARK: Get now weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params1).responseJSON { response in
            
            if let js = response.result.value {
                
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
                
            }// else {
                // No internet
            //}
        }
        
        // MARK: Get next weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: params2).responseJSON { response in
                
            if let js = response.result.value {
                
                let data = JSON(js)
                print("\n/////2nd: \(data)") // Debug
                
                func convertToRoundInt(d: Double?) -> Int {
                    return Int( round(d ?? 0.0) )
                }
                
                // Today temperatures
                self.weatherData.todayTemps[0] = convertToRoundInt(data["list"][0]["temp"]["night"].double)
                self.weatherData.todayTemps[1] = convertToRoundInt(data["list"][0]["temp"]["morn"].double)
                self.weatherData.todayTemps[2] = convertToRoundInt(data["list"][0]["temp"]["day"].double)
                self.weatherData.todayTemps[3] = convertToRoundInt(data["list"][0]["temp"]["eve"].double)
                
                let count = data["cnt"].int ?? 0
                for i in 0..<count {
                    
                    // Next day & night temperatures
                    self.weatherData.nextTemp[i].day = Int( round(data["list"][i]["temp"]["day"].double ?? 0.0) )
                    self.weatherData.nextTemp[i].night = Int( round(data["list"][i]["temp"]["night"].double ?? 0.0) )
                    
                    // Next days weather
                    self.weatherData.nextWeather[i] = data["list"][i]["weather"][0]["main"].string ?? "—"
                    
                    // Set week day name
                    if let unix = data["list"][i]["dt"].double {
                        self.weatherData.nextWeekDays[i] = self.getDayNameUnix(unix)
                        //print("week = " + self.getDayNameUnix(unix))
                    }
                }
                
                self.setNextWeatherOutlets()
                
            }// else {
                // No internet
            //}
        }
    }
    
    func setNowWeatherOutlets() {
        
        self.navigationItem.title = self.currentCity
        
        self.outNowTemp.text = String(self.weatherData.nowTemp) + "°"
        self.outNowWeather.text = self.weatherData.nowWeather
        self.outNowWindSpeed.text = String(self.weatherData.nowWindSpeed) + " км/ч"
        self.outNowPressure.text = String(self.weatherData.nowPressure) + " кПа"
    }
    
    func setNextWeatherOutlets() {
        
        for i in 0...3 {
            self.outTodayTemps[i].text = String(self.weatherData.todayTemps[i]) + "°"
        }
        
        for i in 0...5 {
            self.outNextTempsDay[i].text = String(self.weatherData.nextTemp[i].day)  + "°"
            self.outNextTempsNight[i].text = String(self.weatherData.nextTemp[i].night)  + "°"
            self.outNextWeather[i].text = self.weatherData.nextWeather[i]
            self.outNextWeekDay[i].text = self.weatherData.nextWeekDays[i]
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            return UIInterfaceOrientationMask.Portrait
        }
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
}

