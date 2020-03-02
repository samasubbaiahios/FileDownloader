//
//  URLRequestExtension.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

extension URLRequest {
    init(request: RequestProtocol) {
        let url: URL
        
        if let urlString = request.urlString, let urlObject = URL(string: urlString) {
            url = urlObject
        } else if let networkClient = NetworkAPIClient.shared(),
            let baseUrlStr = networkClient.baseURL,
            let baseURL = URL(string: "\(baseUrlStr)\(request.fullResourcePath)") {
            url = baseURL
        } else {
            fatalError("Could not create URLRequest due to invalid request: \(request)")
        }
        
        self.init(url: url, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
    }
    
    static func withAuthHeader(from request: RequestProtocol) -> URLRequest {
        var urlRequest = URLRequest(request: request)        
        urlRequest.httpMethod = request.httpMethod?.rawValue
        urlRequest.addCustomHeader(from: request)
        // Add common header
        if let requestBody = request.body {
            urlRequest.httpBody = requestBody
        }
        return urlRequest
    }
    
    /// Adds custom header in `URLRequest`
    ///
    /// - Parameters:
    ///    - request: `ORARequestProtocol` instance where the custom header has to be added if it's available
    mutating func addCustomHeader(from request: RequestProtocol) {
        if let customHeader = request.customRequestHeader, !customHeader.isEmpty {
            for key in customHeader.keys {
                if let value = customHeader[key] {
                    self.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
    }
    
    func addCookieHeader() {
        
    }
}
