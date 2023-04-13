//
//  ChooseCityViewController.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-02-12.
//

import UIKit

protocol ChooseCityViewControllerDelegate {
    func didAdd(newlocation: WeatherLocation)
}

class ChooseCityViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: VARs
    
    var allLocations: [WeatherLocation] = []
    var filteredLocations: [WeatherLocation] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let userdefaults = UserDefaults.standard
    var savedLocations: [WeatherLocation]?
    
    var delegate: ChooseCityViewControllerDelegate?
    
    //MARK: View Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadFromUserDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = searchController.searchBar
        setupSearchController()
        setupTapGesture()
        loadLocationsFromCSV()
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = "City or Country"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.addGestureRecognizer(tap)
    }
    
    @objc func tableTapped() {
       dismissView()
    }
    
    //MARK: Get Locations
    
    private func loadLocationsFromCSV() {
        if let path = Bundle.main.path(forResource: "location", ofType: "csv") {
            parseCSVAT(url: URL(fileURLWithPath: path))
        }
    }
    
    private func parseCSVAT(url: URL) {
        
        do {
            let data = try Data(contentsOf: url)
            let dataEndcoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEndcoded?.components(separatedBy: "\n").map({ $0.components(separatedBy: ",") }) {
                
                var i = 0
                for line in dataArr {
                    if line.count > 2 && i != 0 {
                        createLocation(line: line)
                    }
                    i += 1
                }
            }
                
            } catch {
                print("Error reading CSV file, ", error.localizedDescription)
            }
        }
    
        
        private func createLocation(line: [String]) {
            allLocations.append(WeatherLocation(city: line.first!, country: line[1], countryCode: line.last!, isCurrentLocation: false))
            
        }
    
    //MARK: UserDefaults
    
    private func saveToUserDefaults(location: WeatherLocation) {
        if savedLocations != nil {
            if !savedLocations!.contains(location) {
                savedLocations!.append(location)
            }
        } else {
            //if current array is empty
            savedLocations = [location]
        }
        
        userdefaults.set(try? PropertyListEncoder().encode(savedLocations!) , forKey: "Locations")
        userdefaults.synchronize()
    }
    
    private func loadFromUserDefaults() {
        if let data = userdefaults.value(forKey: "Locations") as? Data {
            savedLocations = try? PropertyListDecoder().decode([WeatherLocation].self, from: data)
        }
    }
    
    private func dismissView() {
        if searchController.isActive {
            searchController.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension ChooseCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let location = filteredLocations[indexPath.row]
        cell.textLabel?.text = location.city
        cell.detailTextLabel?.text = location.country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        saveToUserDefaults(location: filteredLocations[indexPath.row])
        delegate?.didAdd(newlocation: filteredLocations[indexPath.row])
        dismissView()
    }
    
    
}

extension ChooseCityViewController: UISearchResultsUpdating {
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredLocations = allLocations.filter({ weatherLocation in
            return weatherLocation.city.lowercased().contains(searchText.lowercased()) || weatherLocation.countryCode.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
    
