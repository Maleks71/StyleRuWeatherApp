//
//  WeatherData.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 08.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import Foundation


class WeatherData {
    
    var nowTemp = 777
    var nowWeather = ""
    var nowWindSpeed = 777
    var nowPressure = 777
    
    var todayTemps = [777, 777, 777, 777]
    
    struct Temp {
        var day = 777
        var night = 777
    }
    
    var nextTemp = [Temp(), Temp(), Temp(), Temp(), Temp(), Temp()]
    var nextWeather = ["", "", "", "", "", ""]
    
}