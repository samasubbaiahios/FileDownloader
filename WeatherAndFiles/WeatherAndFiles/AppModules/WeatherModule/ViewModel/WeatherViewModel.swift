//
//  WeatherViewModel.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation
import CoreData

class WeatherViewModel: NSObject {
    var citiesLog: Observable<[City]> = Observable()
    var cities: [NSManagedObject] = []

    override init() {
        super.init()
        self.getWeatherDetails()
    }
    func getWeatherDetails() {
        fetchAllData()
    }
    func fetchAllData(){
        if CoreDataManager.sharedManager.fetchAllCitiesInfo() != nil {
            let citiesArray = CoreDataManager.sharedManager.fetchAllCitiesInfo()
            citiesLog.value = citiesArray
        }
    }

    func getWeatherFor(cityName: String) {
        let apiCaller = WeatherFetcher.init()
        apiCaller.getWeatherInfo(for: cityName) { (isDone) in
            self.getWeatherDetails()
        }
    }
}
