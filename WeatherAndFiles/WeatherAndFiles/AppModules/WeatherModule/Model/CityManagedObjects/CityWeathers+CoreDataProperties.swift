//
//  CityWeathers+CoreDataProperties.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//
//

import Foundation
import CoreData

extension CityWeathers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityWeathers> {
        return NSFetchRequest<CityWeathers>(entityName: "CityWeathers")
    }

    @NSManaged public var id: Int64
    @NSManaged public var cityName: String?
    @NSManaged public var temp: Double
    @NSManaged public var humid: Double
    @NSManaged public var wind: Double
    @NSManaged public var weather: String?

}
