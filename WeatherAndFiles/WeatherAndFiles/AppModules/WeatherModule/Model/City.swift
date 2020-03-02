//
//  City.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation

class City {
    var cityID: Int
    var cityName: String?
    var temp: Double
    var humid: Double
    var wind: Double
    var weather: String?

    init(fromDict cityInfo: [String: Any]) {
        self.cityID = cityInfo["id"] as? Int ?? 0
        self.temp = 0
        self.humid = 0
        self.wind = 0
        self.weather = "Sunny"
        if cityInfo.keys.count == 6 {
            self.cityName = cityInfo["cityName"] as? String ?? "London"
            self.temp = cityInfo["temp"] as? Double ?? 0
            self.humid = cityInfo["humid"] as? Double ?? 0
            self.wind = cityInfo["windSpeed"] as? Double ?? 0
            self.weather = cityInfo["weatherData"] as? String ?? "Sunny"
        } else {
            self.cityName = cityInfo["name"] as? String ?? "London"
            if let dayInfo = cityInfo["main"] as? [String: Any] {
                self.humid = dayInfo["humidity"] as? Double ?? 0
                self.temp = dayInfo["temp"] as? Double ?? 0
            }
            if let windInfo = cityInfo["wind"] as? [String: Any] {
                self.wind = windInfo["speed"] as? Double ?? 0
            }
            if let weather = cityInfo["weather"] as? [[String: Any]] {
                self.weather = weather[0]["description"] as? String ?? "Sunny"
            }
        }
    }
}
