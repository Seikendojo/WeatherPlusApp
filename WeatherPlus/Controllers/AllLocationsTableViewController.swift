//
//  AllLocationsTableViewController.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-12.
//

import UIKit

protocol AllLocationsTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldRefresh: Bool)
}

class AllLocationsTableViewController: UITableViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var tempSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var footerView: UIView!
    
    //MARK: Vars
    
    var userDefaults = UserDefaults.standard
    var savedLocations: [WeatherLocation]?
    var weatherData: [CityTempData]?
    
    var delegate: AllLocationsTableViewControllerDelegate?
    var shouldRefresh = false
    
    //MARK: View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to have segmented control on the footerView
        tableView.tableFooterView = footerView
        
      loadLocationsFromUserDefaults()
      loadTempFormatFromUserDefaults()
        
    }
    
    //MARK: IBActions
    
    
    @IBAction func temSegmentValueChanged(_ sender: UISegmentedControl) {
        updateTempFormatInUserDeefaults(newValue: sender.selectedSegmentIndex)
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData?.count ?? 0
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainWeatherTableViewCell
        
        if weatherData != nil {
            cell.generateCell(weatherData: weatherData![indexPath.row])
        }

        return cell
    }
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didChooseLocation(atIndex: indexPath.row, shouldRefresh: shouldRefresh)
        self.dismiss(animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle  == .delete {
            let locationToDelete = weatherData?[indexPath.row]
            weatherData?.remove(at: indexPath.row)
            print("delete this..\(locationToDelete?.city)")
            removeLocationFromSavedLocations(location: locationToDelete!.city)
            tableView.reloadData()
        }
    }
    
    private func removeLocationFromSavedLocations(location: String) {
        if savedLocations != nil {
            for i in 0..<savedLocations!.count {
                let tempLocation = savedLocations![i]
                
                if tempLocation.city == location {
                    savedLocations!.remove(at: i)
                    //save userdefaults
                    saveNewLocationsToUserDefaults()
                    return 
                }
            }
        }
    }
    
    
    
    //MARK: UserDefaults
    
    private func saveNewLocationsToUserDefaults() {
        
        shouldRefresh = true
        
        userDefaults.set(try? PropertyListEncoder().encode(savedLocations!), forKey: "Locations")
        userDefaults.synchronize()
    }
    
    private func updateTempFormatInUserDeefaults(newValue: Int) {
        shouldRefresh = true
        userDefaults.set(newValue, forKey: "TempFormat")
        userDefaults.synchronize()
    }
    
    private func loadTempFormatFromUserDefaults() {
        if let index = userDefaults.value(forKey: "TempFormat") {
            tempSegmentOutlet.selectedSegmentIndex = index as! Int
        } else {
            tempSegmentOutlet.selectedSegmentIndex = 0
        }
    }
    
    private func loadLocationsFromUserDefaults() {
        if let data = userDefaults.value(forKey: "Locations") as? Data {
            savedLocations = try? PropertyListDecoder().decode([WeatherLocation].self, from: data)
            print("We have \(savedLocations?.count) locations in UD")
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseLocationSeg" {
            let vc = segue.destination as! ChooseCityViewController
            vc.delegate = self
        }
    }
}

extension AllLocationsTableViewController: ChooseCityViewControllerDelegate {
    func didAdd(newlocation: WeatherLocation) {
        shouldRefresh = true
        weatherData?.append(CityTempData(city: newlocation.city, temp: 0.0))
        tableView.reloadData()
    }
}
