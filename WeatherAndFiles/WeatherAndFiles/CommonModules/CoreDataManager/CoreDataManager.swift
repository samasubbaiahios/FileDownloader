//
//  CoreDataManager.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    private init() {}
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherAndFiles")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /*Insert Item*/
    func insertCityInfo(cityData: City) -> CityWeathers? {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CityWeathers", in: managedContext)!
        let weather = NSManagedObject(entity: entity, insertInto: managedContext)
        weather.setValue(cityData.cityID, forKeyPath: "id")
        weather.setValue(cityData.cityName, forKeyPath: "cityName")
        weather.setValue(cityData.temp, forKeyPath: "temp")
        weather.setValue(cityData.humid, forKeyPath: "humid")
        weather.setValue(cityData.wind, forKeyPath: "wind")
        weather.setValue(cityData.weather, forKeyPath: "weather")

        do {
            try managedContext.save()
            return weather as? CityWeathers
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /* Add and Update items */
    func addedOrUpdate(cityData: City) -> CityWeathers?  {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CityWeathers")
        let predicate = NSPredicate(format: "id = '\(cityData.cityID)'")
        fetchRequest.predicate = predicate
        do
        {
            let object = try context.fetch(fetchRequest)
            if object.count == 0 {
                //If the record is not exists
                return self.insertCityInfo(cityData: cityData)
            } else {
                //Update all data based for the existing record
                let weather = object.first
                weather?.setValue(cityData.cityName, forKey: "cityName")
                weather?.setValue(cityData.temp, forKey: "temp")
                weather?.setValue(cityData.humid, forKey: "humid")
                weather?.setValue(cityData.wind, forKey: "wind")
                weather?.setValue(cityData.weather, forKey: "weather")
                do{
                    try context.save()
                    return weather as? CityWeathers
                }
                catch
                {
                    print(error)
                    return nil
                }
            }
        }
        catch
        {
            print(error)
            return nil
        }
    }
    /*Fetch Request*/
    func fetchAllCitiesInfo() -> [City]?{
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CityWeathers")
        do {
            let cities = try managedContext.fetch(fetchRequest)
            var citiesArray = [City]()
            for city in cities {
                let cityId = city.value(forKey: "id")
                let cityName = city.value(forKey: "cityName")
                let temp = city.value(forKey: "temp")
                let humid = city.value(forKey: "humid")
                let wind = city.value(forKey: "wind")
                let weather = city.value(forKey: "weather")
                let dataDict = ["id": cityId, "cityName": cityName, "temp": temp, "humid": humid, "windSpeed": wind, "weatherData":weather]
                let cityModel = City.init(fromDict: dataDict as [String : Any])
                citiesArray.append(cityModel)
            }
            return citiesArray
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    /*Delete City*/
    func delete(cityData: City) -> [CityWeathers]? {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CityWeathers")
        fetchRequest.predicate = NSPredicate(format: "id = '\(cityData.cityID)'")
        do {
            let items = try managedContext.fetch(fetchRequest)
            var arrRemovedPeople = [CityWeathers]()
            for item in items {
                managedContext.delete(item)
                try managedContext.save()
                arrRemovedPeople.append(item as! CityWeathers)
            }
            return arrRemovedPeople
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        
    }
    /*delete*/
    func delete(person : CityWeathers){
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        managedContext.delete(person)
        do {
            try managedContext.save()
        } catch {
            // Do something in response to error condition
        }
    }
}

