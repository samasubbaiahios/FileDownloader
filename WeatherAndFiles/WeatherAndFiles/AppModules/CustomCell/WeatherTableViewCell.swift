//
//  WeatherTableViewCell.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    static let kWeatherCellID = "weatherCell"
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var cityName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var viewModel: CityCellViewModel? {
        didSet {
            let cityModel: City = viewModel?.getLog() ?? City.init(fromDict: [:])
            self.cityName.text = cityModel.cityName
            self.cityName.font = UIFont.systemFont(ofSize: 16)
            self.cityName.textColor = UIColor.black
            
            self.temp.text = String(cityModel.temp) + "C"
            self.temp.font = UIFont.systemFont(ofSize: 15)
            self.temp.textColor = UIColor.black

            self.windSpeed.text = "Wind Speed: " + String(cityModel.wind) + " kmph"
            self.windSpeed.font = UIFont.systemFont(ofSize: 15)
            self.windSpeed.textColor = UIColor.lightGray

            self.humidity.text = "Humidity: " + String(cityModel.humid) + " %"
            self.humidity.font = UIFont.systemFont(ofSize: 15)
            self.humidity.textColor = UIColor.lightGray

            self.weatherDesc.text = cityModel.weather
            self.weatherDesc.font = UIFont.systemFont(ofSize: 15)
            self.weatherDesc.textColor = UIColor.black

        }
    }
}
@objc extension WeatherTableViewCell: Configurable {
    typealias T = CityCellViewModel
    func bind(to model: CityCellViewModel) {
        self.viewModel = model
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
