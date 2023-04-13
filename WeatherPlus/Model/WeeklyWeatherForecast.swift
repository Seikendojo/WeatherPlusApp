//
//  WeeklyWeatherForecast.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-16.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeeklyWeatherForecast {
    
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
    
    
    class func dowloadWeaklyWeatherForecast(location: WeatherLocation, complition: @escaping (_ weatherForecast: [WeeklyWeatherForecast]) -> Void) {
        
         var WeeklyFORECAST_URL: String!
         
         if !location.isCurrentLocation {
             WeeklyFORECAST_URL = String(format: "https://api.weatherbit.io/v2.0/forecast/daily?city=%@,%@&days=7&key=71b735f7a3954a7c9de3e974421b7e11", location.city, location.countryCode)
             
         } else {
             WeeklyFORECAST_URL = CURRENTLOCATIONWEEKLYFORECAST_URL
         }
        
        Alamofire.request(WeeklyFORECAST_URL).responseJSON { response in
            let result = response.result
            
            var forecastArray: [WeeklyWeatherForecast] = []
            
            if result.isSuccess {
                if let dictionary = result.value as? Dictionary<String,AnyObject> {
                    if var list = dictionary["data"] as? [Dictionary<String,AnyObject>] {
                        
                        list.remove(at: 0)  
                        
                        for item in list {
                            let forcast = WeeklyWeatherForecast(weatherDictionary: item)
                            forecastArray.append(forcast)
                        }
                    }
                }
                complition(forecastArray)
            } else {
                complition(forecastArray)
                print("No weekly forecast..")
            }
        }
    }
}
