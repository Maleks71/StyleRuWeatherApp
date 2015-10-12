//
//  WeatherData.swift
//  StyleRuWeatherApp
//
//  Created by Григорий Стригунов on 08.10.15.
//  Copyright © 2015 Grigory Strigunov. All rights reserved.
//

import Foundation


class WeatherData {
    
    var nowTemp = 0
    var nowWeather: String? = ""
    var nowWindSpeed = 0
    var nowPressure = 0
    
    var todayTemps = [0, 0, 0, 0]
    
    struct Temp {
        var day = 0
        var night = 0
    }
    
    var nextTemp = [Temp(), Temp(), Temp(), Temp(), Temp(), Temp()]
    var nextWeather = ["", "", "", "", "", ""]
    var nextWeekDays = ["", "", "", "", "", ""]
}