//
//  WeatherAPI.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation

class WeatherAPI {

    static var apiClient: NetworkAPIClient?
    
    static func setupClient() {
        apiClient = NetworkAPIClient.create(baseUrl: Constants.urlConstants.kBaseURL)
        NetworkAPIClient.setSharedClient(apiClient)
    }
    
    static func getWeatherInfo(for city: String, completion: @escaping (ResponseHandler)) {
        var weatherRequest = NetworkRequest(resourcePath: Constants.urlConstants.kWeatherNode)
        weatherRequest.shouldIgnoreCacheData = true
        var queryParams = QueryParam()
        queryParams["q"] = city
        queryParams["appid"] = Constants.urlConstants.kAppID
        
        if !queryParams.isEmpty {
            weatherRequest.queryParams = queryParams
        }
        apiClient?.send(request: weatherRequest, completionCallback: completion)
    }
}
