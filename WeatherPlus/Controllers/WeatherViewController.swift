//
//  WeatherViewController.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-20.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    //MARK: IBOutlets

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var weatherScrolView: UIScrollView!
    
    
    //MARK: Vars
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D!
    let userDefaults = UserDefaults.standard
    
    var allLocations: [WeatherLocation] = []
    var allWeatherViews: [WeatherView] = []
    var allWeatherData: [CityTempData] = []
   
    var shouldRefresh = true
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerStart()
        weatherScrolView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if shouldRefresh {
            allLocations = []
            allWeatherViews = []
            print("we have \(weatherScrolView.subviews.count)")
            removeViewsFromScrollView()
            locationAuthCheck()
        }
        
    }
    
    //Update location manager when we don't need it anymore
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationManagerStop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        weatherScrolView.frame = view.bounds
        weatherScrolView.contentSize.height = allWeatherViews.first?.bounds.height ?? 0
    }

    //MARK: Download Weather
    private func getWeather() {
        loadLocationsFromUserDefaults()
        createWeatherViews()
        addWeatherToScrollView()
        setPageControlPageNumber()
       
    }
    
    private func removeViewsFromScrollView() {
        for view in weatherScrolView.subviews {
            view.removeFromSuperview()
        }
    }
    
    private func createWeatherViews() {
        for _ in allLocations {
            allWeatherViews.append(WeatherView())
        }
    }
    
   func addWeatherToScrollView() {
       
        for i in 0..<allWeatherViews.count {
            
            let weatherView = allWeatherViews[i]
            let location = allLocations[i]
            getcurrentWeather(weatherView: weatherView, location: location)
            getWeeklyWeather(weatherView: weatherView, location: location)
            getHourlyWeather(weatherView: weatherView, location: location)
            
            let xPos = self.view.frame.width * CGFloat(i)
            weatherView.frame = CGRect(x: xPos, y: 0, width: weatherScrolView.bounds.width, height: weatherScrolView.bounds.height)
            weatherScrolView.addSubview(weatherView)
            weatherScrolView.contentSize.width = weatherView.frame.width * CGFloat(i + 1)
        }
    }
    
    private func getcurrentWeather(weatherView: WeatherView, location: WeatherLocation) {
    weatherView.currentWeather = CurrentWeather()
        weatherView.currentWeather.getCurrentWaether(location: location) { success in
        weatherView.refreshData()
        
            self.generateWeatherList()
            
      }
        
    }
 
    private func getWeeklyWeather(weatherView: WeatherView, location: WeatherLocation) {
        WeeklyWeatherForecast.dowloadWeaklyWeatherForecast(location: location) { weatherForecast in
            weatherView.weeklyWeatherForecastData = weatherForecast
            weatherView.tableView.reloadData()
        }
    }

    private func getHourlyWeather(weatherView: WeatherView, location: WeatherLocation) {
        HourlyForecast.downloadHourlyForecastWeather(location: location) { hourlyForecast in
            weatherView.dailyWeatherForecastData = hourlyForecast
            weatherView.hourlyCollectionView.reloadData()
        }
    }
    
    //MARK: Load locations from user defaults
    
    private func loadLocationsFromUserDefaults() {
        let currentLocation = WeatherLocation(city: "", country: "", countryCode: "", isCurrentLocation: true)
        if let data = userDefaults.value(forKey: "Locations") as? Data {
            allLocations = try! PropertyListDecoder().decode([WeatherLocation].self, from: data)
            allLocations.insert(currentLocation, at: 0)
            
        } else {
            print("No user data in user defaults")
            //If we didn't have anything in userdefaults
            allLocations.append(currentLocation)
        }
    }
    
    //MARK: PageControl
    
    private func setPageControlPageNumber() {
        pageControl.numberOfPages = allWeatherViews.count
    }
    
    private func updatePageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    
    //MARK: Location Manager
    
    private func locationManagerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            //ask user aauth.
            //add the location auth privacy and note to Plist
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.delegate = self
            locationManager!.startMonitoringSignificantLocationChanges()
        }
    }
    
    private func locationManagerStop() {
        if locationManager != nil {
            locationManager!.stopMonitoringSignificantLocationChanges()
        }
    }
    
    private func locationAuthCheck() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager!.location?.coordinate
            
            if currentLocation != nil {
                LocationService.shared.latitude = currentLocation.latitude
                LocationService.shared.longitude = currentLocation.longitude
                //Get the weather
                getWeather()
            } else {
                locationAuthCheck()
            }
        } else {
            locationManager?.requestWhenInUseAuthorization()
            locationAuthCheck()
        }
    }
    
    private func generateWeatherList() {
        allWeatherData = []
        
        for weatherView in allWeatherViews {
            allWeatherData.append(CityTempData(city: weatherView.currentWeather.city, temp: weatherView.currentWeather.currentTemp))
        }
    }
    
    //MARK: Navogation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allLocationSeg" {
            let vc = segue.destination as! AllLocationsTableViewController
            vc.weatherData = allWeatherData
            vc.delegate = self
        }
    }
}

extension WeatherViewController: AllLocationsTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldRefresh: Bool) {
        let viewNumber = CGFloat(integerLiteral: atIndex)
        let newOffset = CGPoint(x: (weatherScrolView.frame.width + 1.0) * viewNumber, y: 0)
        
        weatherScrolView.setContentOffset(newOffset, animated: true)
        updatePageControlSelectedPage(currentPage: atIndex)
        
        self.shouldRefresh = shouldRefresh
    }
}


extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Faild to get location, \(error.localizedDescription)")
    }
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Get how many objects we have in scrollView
        let value = weatherScrolView.contentOffset.x / weatherScrolView.frame.size.width
        updatePageControlSelectedPage(currentPage: Int(round(value)))
    }
}



