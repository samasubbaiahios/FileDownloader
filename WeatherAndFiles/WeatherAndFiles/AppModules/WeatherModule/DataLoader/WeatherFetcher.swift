//
//  WeatherFetcher.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation

class WeatherFetcher: NSObject {
    
    override init() {
        super.init()
    }

    /*Fetch the entered city weather repor. (The API is returning only London report, even passing proper query parameters example: https://samples.openweathermap.org/data/2.5/weather?q=Newyork&appid=62e11039ca7618dff5ebc21cdee9229d)
     */
    func getWeatherInfo(for city: String, completion: @escaping (finishedHandler)) {
        WeatherAPI.setupClient()
        WeatherAPI.getWeatherInfo(for: city) { apiResponse in
            if let jsonRes = apiResponse.asJSON() {
                let cityModel = City.init(fromDict: jsonRes)
                //To Avoid duplicate entries.
                let savedContext = CoreDataManager.sharedManager.addedOrUpdate(cityData: cityModel)
                
                //For duplicate entries use this, un comment below line comment above line
//                let savedContext = CoreDataManager.sharedManager.insertCityInfo(cityData: cityModel)
                
                if savedContext != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
}
