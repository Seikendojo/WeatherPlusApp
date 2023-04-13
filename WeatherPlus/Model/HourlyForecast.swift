//
//  HourlyForecast.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-12.
//

import Foundation
import Alamofire
import SwiftyJSON

class HourlyForecast {
    private var _date: Date!
    private var _temp: Double!
    private var _weatherIcon: String!
    
    var date: Date {
        if _date == nil {
            _date = Date()
        }
        return _date
    }
    
    var temp: Double {
        if _temp == nil {
            _temp = 0.0
        }
        return _temp
    }
    
    var weatherIcon: String {
        if _weatherIcon == nil {
            _weatherIcon = ""
        }
        return _weatherIcon
    }
    
    init(weatherDictionary: Dictionary<String,AnyObject>) {
        let json = JSON(weatherDictionary)
        self._temp = getTempBasedOnSetting(celsius: json["temp"].double ?? 0.0)
        self._date = currentDateFromUnix(unixDate: json["ts"].double!)
        self._weatherIcon = json["weather"]["icon"].stringValue
    }
    
    
    
    class func downloadHourlyForecastWeather(location: WeatherLocation, complition: @escaping (_ hourlyForecast: [HourlyForecast]) -> Void) {
        
        var HOURLYFORECAST_URL: String!
        
        if !location.isCurrentLocation {
            HOURLYFORECAST_URL = String(format: "https://api.weatherbit.io/v2.0/forecast/hourly?city=%@,%@&hours=24&key=71b735f7a3954a7c9de3e974421b7e11", location.city, location.countryCode)
            
        } else {
            HOURLYFORECAST_URL = CURRENTLOCATIONHOURLYFORECAST_URL
        }
        
        
        Alamofire.request(HOURLYFORECAST_URL).responseJSON { response in
            let result = response.result
            
            var forcastArray: [HourlyForecast] = []
            
            if result.isSuccess {
                let json = result.value
                
                if let dictionary = json as? Dictionary<String, AnyObject> {
                    if let list = dictionary["data"] as? [Dictionary<String,AnyObject>] {
                        for item in list {
                            let forcast = HourlyForecast(weatherDictionary: item)
                            forcastArray.append(forcast)
                        }
                    }
                }
                
                complition(forcastArray)
                
            } else {
                complition(forcastArray)
                print("No forecast data")
            }
        }
    }
}
