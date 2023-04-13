//
//  WeatherLocation.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-12.
//

import Foundation

struct WeatherLocation: Codable,Equatable {
    var city: String!
    var country: String!
    var countryCode: String!
    var isCurrentLocation: Bool!
}


