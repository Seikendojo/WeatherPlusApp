//
//  MainWeatherTableViewCell.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-13.
//

import UIKit

class MainWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateCell(weatherData: CityTempData) {
        cityLabel.text = weatherData.city
        cityLabel.adjustsFontSizeToFitWidth = true
        //set double with no decimal
        tempLabel.text = String(format: "%.0f %@", weatherData.temp, returnTempFormatFromUserDefaults())
    }
}
