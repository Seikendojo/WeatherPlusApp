//
//  APIURLS.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-12.
//

import Foundation


let CURRENTLOCATION_URL = "https://api.weatherbit.io/v2.0/current?&lat=\(LocationService.shared.latitude!)&lon=\(LocationService.shared.longitude!)&key=71b735f7a3954a7c9de3e974421b7e11&include=minutely"
let CURRENTLOCATIONWEEKLYFORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/daily?lat=\(LocationService.shared.latitude!)&lon=\(LocationService.shared.longitude!)&days=7&key=71b735f7a3954a7c9de3e974421b7e11"
let CURRENTLOCATIONHOURLYFORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/hourly?lat=\(LocationService.shared.latitude!)&lon=\(LocationService.shared.longitude!)&hours=24&key=71b735f7a3954a7c9de3e974421b7e11"

