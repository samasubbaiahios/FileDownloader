//
//  NetworkRequest.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation

struct NetworkRequest: RequestProtocol {
    
    
    var responseProcessor: APIResponseProcessor?
    var urlString: String?
    var contentType: HTTPContentType?
    var httpMethod: HTTPMethod?
    var resourcePath: String
    var pathParam: String?
    var queryParams: [String: String]?
    var customRequestHeader: [String: String]?
    var body: Data?
    private var requestTimeoutInterval: TimeInterval = 180
    var shouldIgnoreCacheData: Bool
    
    init(resourcePath: String,
         httpMethod: HTTPMethod? = .get,
         pathParam: String? = nil,
         requestHeader: [String: String]? = nil,
         queryParams: [String: String]? = nil,
         contentType: HTTPContentType? = .json,
         urlString: String? = nil,
         shouldIgnoreCacheData: Bool = false) {
        self.httpMethod = httpMethod
        self.resourcePath = resourcePath
        self.pathParam = pathParam
        self.queryParams = queryParams
        self.customRequestHeader = requestHeader
        self.urlString = urlString
        self.shouldIgnoreCacheData = shouldIgnoreCacheData
    }
    
    var timeoutInterval: TimeInterval {
        get {
            return requestTimeoutInterval
        } set {
            requestTimeoutInterval = newValue
        }
    }
//    func objectTypeForRequest() -> Any? {
//        let objectClass = RequestObjectMapper.shared().objectClass(for: resourcePath)
//        return objectClass
//    }
//    
//    func entityClassForRequest() -> Any? {
//        if let entityClass = RequestObjectMapper.shared().objectClass(for: resourcePath) {
//            return entityClass
//        }
//        return nil
//    }
//    
//    func entityNameForRequest() -> String? {
//        let entityName = RequestObjectMapper.shared().entityName(for: resourcePath)
//        return entityName
//    }
    
    static func apiRequest(from resourcePath: String, entity entityName: String, mappedTo objectClass: Any?=nil, responseProcessor: APIResponseProcessor?=nil) -> NetworkRequest {
        var apiRequest = NetworkRequest(resourcePath: resourcePath)
        apiRequest.responseProcessor = responseProcessor
        RequestObjectMapper.shared().mapObjectClass(objectClass, toRequestPath: resourcePath)
        RequestObjectMapper.shared().mapEntityName(entityName, toRequestPath: resourcePath)
        return apiRequest
    }
}

extension NetworkRequest {
    public var fullResourcePath: String {
        var path = "\(resourcePath)"
        
        if let param = pathParam {
            path += "/\(param)"
        }
        
        if let queryParam = queryParams {
            path += queryParam.toQueryString().urlEncodedString
        }
        
        return path
    }
    
    func uniqueIdentifier() -> String {
        var uniqueId = resourcePath.replacingOccurrences(of: "/", with: "_")
        
        if let param = pathParam {
            uniqueId += "_\(param)"
        }
        
        if let queryParam = queryParams {
            uniqueId += queryParam.values.joined(separator: "_")
        }
        
        return uniqueId
    }
}

