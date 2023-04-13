//
//  ForecastCollectionViewCell.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-31.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {

//MARK: IBOutlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func generateCell(weather: HourlyForecast) {
        timeLabel.text = weather.date.time()
        weatherIconImageView.image = getWeatherIconFor(weather.weatherIcon)
        tempLabel.text = String(format: "%.0f%@", weather.temp, returnTempFormatFromUserDefaults())
        
    }

}
