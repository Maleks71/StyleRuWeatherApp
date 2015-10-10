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

    let weatherData = WeatherData()
    
    
    // This func will removed after App testing
    func set_task(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getWeatherData()
    }
    
    // MARK: Get weather data
    func getWeatherData() {
        
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
        
        // MARK: Get now weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: params1).responseJSON { response in
            
            if let js = response.result.value {
                
                let data = JSON(js)
                print("\n/////1st: \(data)")
                
                if let nowTemp = data["main"]["temp"].double {
                    self.weatherData.nowTemp = Int( round(nowTemp) )
                }
                
                self.weatherData.nowWeather = data["weather"][0]["main"].string ?? "?"
                
                if let nowWindSpeed = data["wind"]["speed"].int {
                    let convert = round( Double(nowWindSpeed) * 3.6 )
                    self.weatherData.nowWindSpeed = Int(convert)
                }
                
                if let nowPressure = data["main"]["pressure"].int {
                    self.weatherData.nowPressure = nowPressure
                }
                
                self.setNowWeatherOutlets()
            }
        }
        
        // MARK: Get next weather
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: params2)
            .responseJSON { response in
                
                if let js = response.result.value {
                    
                    let data = JSON(js)
                    print("\n/////2nd: \(data)")
                    
                    func convertToRoundInt(d: Double?) -> Int {
                        return Int( round(d ?? 777.0) )
                    }
                    
                    self.weatherData.todayTemps[0] = convertToRoundInt(data["list"][0]["temp"]["night"].double)
                    self.weatherData.todayTemps[1] = convertToRoundInt(data["list"][0]["temp"]["morn"].double)
                    self.weatherData.todayTemps[2] = convertToRoundInt(data["list"][0]["temp"]["day"].double)
                    self.weatherData.todayTemps[3] = convertToRoundInt(data["list"][0]["temp"]["eve"].double)
                    
                    let count = data["cnt"].int ?? 0
                    for i in 0..<count {
                        
                        self.weatherData.nextTemp[i].day = Int( round(data["list"][i]["temp"]["day"].double ?? 777.0) )
                        self.weatherData.nextTemp[i].night = Int( round(data["list"][i]["temp"]["night"].double ?? 777.0) )
                        
                        self.weatherData.nextWeather[i] = data["list"][i]["weather"][0]["main"].string ?? "?"
                    }
                    
                    self.setNextWeatherOutlets()
                }
        }
        
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
        
        outNowTemp.text = String(self.weatherData.nowTemp) + "°"
        outNowWeather.text = self.weatherData.nowWeather
        outNowWindSpeed.text = String(self.weatherData.nowWindSpeed) + " km/h"
        outNowPressure.text = String(self.weatherData.nowPressure) + " hPa"
        
        outTodayTemps[0].text = String(self.weatherData.todayTemps[0])
        outTodayTemps[1].text = String(self.weatherData.todayTemps[1])
        outTodayTemps[2].text = String(self.weatherData.todayTemps[2])
        outTodayTemps[3].text = String(self.weatherData.todayTemps[3])
        
        outNextTempsDay[0].text = String(self.weatherData.nextTemp[0].day)
        outNextTempsDay[1].text = String(self.weatherData.nextTemp[1].day)
        outNextTempsDay[2].text = String(self.weatherData.nextTemp[2].day)
        outNextTempsDay[3].text = String(self.weatherData.nextTemp[3].day)
        outNextTempsDay[4].text = String(self.weatherData.nextTemp[4].day)
        outNextTempsDay[5].text = String(self.weatherData.nextTemp[5].day)
        
        outNextTempsNight[0].text = String(self.weatherData.nextTemp[0].night)
        outNextTempsNight[1].text = String(self.weatherData.nextTemp[1].night)
        outNextTempsNight[2].text = String(self.weatherData.nextTemp[2].night)
        outNextTempsNight[3].text = String(self.weatherData.nextTemp[3].night)
        outNextTempsNight[4].text = String(self.weatherData.nextTemp[4].night)
        outNextTempsNight[5].text = String(self.weatherData.nextTemp[5].night)
    }
    
    func setNextWeatherOutlets() {
        
    }
    
}

