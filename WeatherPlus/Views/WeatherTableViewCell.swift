//
//  WeatherTableViewCell.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-01.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    //MARK: IBOutlets
    
    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateCell(forecast: WeeklyWeatherForecast) {
        dayOfTheWeekLabel.text = forecast.date.dayOfTheWeek()
        weatherIconImageView.image = getWeatherIconFor(forecast.weatherIcon)
        tempLabel.text = String(format: "%.0f%@", forecast.temp, returnTempFormatFromUserDefaults())
    }
}
