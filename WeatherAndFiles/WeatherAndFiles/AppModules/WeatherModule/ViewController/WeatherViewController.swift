//
//  WeatherViewController.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    var citiesViewModel: WeatherViewModel?

    @IBOutlet weak var weathersTable: UITableView!
    @IBOutlet weak var addCityWeatherButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uiStyles()
    }
    func uiStyles() {
        self.weathersTable.rowHeight = UITableView.automaticDimension
        self.weathersTable.estimatedRowHeight = UITableView.automaticDimension
        self.weathersTable.tableFooterView = UIView()
    }
    @IBAction func addNewCity(_ sender: Any) {
        enterNewCityInfo()
    }
    // MARK: - Actions
    /// City Action
    @objc
    private func enterNewCityInfo() {
        let alert = UIAlertController(title: "Weather", message: "Get Weather For", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textFieldName) in
            textFieldName.placeholder = "Enter City"
        })
        let saveAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                let enteredCity = textField.text else {
                    return
            }
            self.citiesViewModel?.getWeatherFor(cityName: enteredCity)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let logList = self.citiesViewModel?.citiesLog.value {
            return logList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.kWeatherCellID) as! WeatherTableViewCell
        if let logList = self.citiesViewModel?.citiesLog.value {
            cell.bind(to: CityCellViewModel(cityInfo: logList[indexPath.row]))
        }
        return cell
    }
}

@objc extension WeatherViewController: Configurable {
    typealias T = WeatherViewModel
    func bind(to model: WeatherViewModel) {
        self.citiesViewModel = model
        self.citiesViewModel?.observe(for: [self.citiesViewModel!.citiesLog], with: { [weak self] (_) in
            self?.weathersTable.reloadData()
        })
    }
}
