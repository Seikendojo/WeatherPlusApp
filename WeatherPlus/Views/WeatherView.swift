//
//  WeatherView.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-23.
//

import Foundation
import UIKit

class WeatherView: UIView {
 
    

    //MARK: IBOutlets
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherInfoLabel: UILabel!
    @IBOutlet weak var weatherScrollView: UIScrollView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var infoCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: VARs
    var currentWeather: CurrentWeather!
    var weeklyWeatherForecastData : [WeeklyWeatherForecast] = []
    var dailyWeatherForecastData: [HourlyForecast] = []
    var weatherInfoData: [WeatherInfo] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
        mainInit()
    }
    
    private func mainInit() {
        Bundle.main.loadNibNamed("WeatherView", owner: self)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        setupTableView()
        setupHourlyCollectionView()
        setupInfoCollectionView()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupHourlyCollectionView() {
        hourlyCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        hourlyCollectionView.dataSource = self
    }
 
    private func setupInfoCollectionView() {
        infoCollectionView.register(UINib(nibName: "InfoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        infoCollectionView.dataSource = self
    }
    
    
    func refreshData() {
        setupCurrentWeather()
        setupWeatherInfo()
        infoCollectionView.reloadData()
    }
    
    private func setupCurrentWeather() {
        cityName.text = currentWeather.city
        dateLabel.text = "Today,  \(currentWeather.date.shortDate())"
        tempLabel.text = String(format: "%.0f%@", currentWeather.currentTemp, returnTempFormatFromUserDefaults())
        
        weatherInfoLabel.text =  currentWeather.weatherType
    }
    
    private func setupWeatherInfo() {
        let windInfo = WeatherInfo(infoText: String(format: "%.1f m/sec", currentWeather.windSpeed), nameText: nil, image: getWeatherIconFor("wind"))
        let humiduty = WeatherInfo(infoText: String(format: "%.0f", currentWeather.humidity), nameText: nil, image: getWeatherIconFor("humidity"))
        let pressureInfo = WeatherInfo(infoText: String(format: "%.0f mb", currentWeather.pressure), nameText: nil, image: getWeatherIconFor("pressure"))
        let visibility = WeatherInfo(infoText: String(format: "%.1f km", currentWeather.visibility), nameText: nil, image: getWeatherIconFor("visibility"))
        let feelsLikeInfo = WeatherInfo(infoText: String(format: "%.1f", currentWeather.feelsLike), nameText: nil, image: getWeatherIconFor("feelsLike"))
        let uvInfo = WeatherInfo(infoText: String(format: "%.1f", currentWeather.uv), nameText: "UV Index", image: nil)
        let sunriseInfo = WeatherInfo(infoText: currentWeather.sunrise, nameText: nil, image: getWeatherIconFor("sunrise"))
        let sunsetInfo = WeatherInfo(infoText: currentWeather.sunset, nameText: nil, image: getWeatherIconFor("sunset"))
        
        weatherInfoData = [windInfo,humiduty,pressureInfo,visibility,feelsLikeInfo,uvInfo,sunriseInfo,sunsetInfo]
    }
    
}


extension WeatherView: UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeatherForecastData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherTableViewCell
        cell.generateCell(forecast: weeklyWeatherForecastData[indexPath.row])
        return cell
    }
}

extension WeatherView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hourlyCollectionView {
            return dailyWeatherForecastData.count
        } else {
            return weatherInfoData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hourlyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ForecastCollectionViewCell
            cell?.generateCell(weather: dailyWeatherForecastData[indexPath.row])
            return cell!
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? InfoCollectionViewCell
            cell?.generateCell(weatherInfo: weatherInfoData[indexPath.row])
            return cell!
        }
    }
    
    
    
    
}
