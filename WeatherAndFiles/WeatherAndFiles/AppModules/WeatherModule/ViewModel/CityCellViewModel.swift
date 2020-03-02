//
//  CityCellViewModel.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation
class CityCellViewModel: NSObject {
    var cityLog : City
    
    init(cityInfo: City) {
        self.cityLog = cityInfo
    }
    func getLog() -> City {
        return cityLog
    }
}
