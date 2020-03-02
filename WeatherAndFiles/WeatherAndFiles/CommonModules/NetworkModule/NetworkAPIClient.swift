//
//  NetworkAPIClient.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

class NetworkAPIClient {
    
    var baseUrl: String
    
    private static var sharedClient: NetworkAPIClient?
    
    private init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    static func create(baseUrl: String) -> NetworkAPIClient {
        let client = NetworkAPIClient(baseUrl: baseUrl)
        return client
    }
    
    public static func shared() -> NetworkAPIClient? {
        if sharedClient != nil {
            return sharedClient
        }
        
        return nil
    }
    
    public static func setSharedClient(_ client: NetworkAPIClient?) {
        sharedClient = client
    }
    
    public var baseURL: URL? {
        return URL(string: baseUrl)
    }
    
    func send(request: RequestProtocol, completionCallback: @escaping (ResponseHandler)) {
        NetworkManager.shared().startLoading(request: request, with: completionCallback)
    }
    func download(request: RequestProtocol, completionCallback: @escaping (ResponseHandler)) {
        
    }
}
