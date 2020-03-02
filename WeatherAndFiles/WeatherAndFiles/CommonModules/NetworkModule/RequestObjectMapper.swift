//
//  RequestObjectMapper.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 25/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import Foundation

class RequestObjectMapper {
    var requestPath2ObjectClassMapping: [String: Any]
    var requestPath2EntityNameMapping: [String: String]
    
    private static var sharedMapper: RequestObjectMapper!
    
    static func shared() -> RequestObjectMapper {
        if sharedMapper == nil {
            sharedMapper = RequestObjectMapper()
        }
        
        return sharedMapper
    }
    
    private init() {
        requestPath2ObjectClassMapping = [String: Any]()
        requestPath2EntityNameMapping = [String: String]()
    }
    
    func mapObjectClass(_ objectClass: Any?, toRequestPath requestPath: String) {
        guard let objectClass = objectClass else { return }
        
        let requestPaths = requestPath2ObjectClassMapping.keys
        
        if !requestPaths.contains(requestPath) {
            requestPath2ObjectClassMapping[requestPath] = objectClass
        }
    }
    
    func objectClass(for resourcePath: String) -> Any? {
        if let objectCls = requestPath2ObjectClassMapping[resourcePath] {
            return objectCls
        }
        return nil
    }
    
    func mapEntityName(_ entityName: String, toRequestPath requestPath: String) {
        let requestPaths = requestPath2EntityNameMapping.keys
        
        if !requestPaths.contains(requestPath) {
            requestPath2EntityNameMapping[requestPath] = entityName
        }
    }
    
    func entityName(for resourcePath: String) -> String? {
        let nameOfEntity = requestPath2EntityNameMapping[resourcePath]
        return nameOfEntity
    }
}
