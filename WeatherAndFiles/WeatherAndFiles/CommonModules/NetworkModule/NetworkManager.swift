//
//  NetworkManager.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import UIKit

typealias ResponseHandler = ((NetworkAPIResponse) -> Void)
typealias finishedHandler = (Bool) -> Void

class NetworkManager: NSObject {
    private static var sharedManager: NetworkManager!
    
    public static func shared() -> NetworkManager {
        if let sharedObject = sharedManager {
            return sharedObject
        } else {
            sharedManager = NetworkManager()
            return sharedManager
        }
    }
    
    override private init() {
    }
    
    func startLoading(request: RequestProtocol, with completionCallback: @escaping (ResponseHandler)) {
//        let urlRequest = URLRequest.withAuthHeader(from: request)
        let urlRequest = URLRequest(request: request)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 180
        let activeSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = activeSession.dataTask(with: urlRequest) { data, urlResponse, error in
            let response = NetworkAPIResponse(request: request, urlResponse: urlResponse, data: data, error: error)
            completionCallback(response)
        }
        task.resume()
        activeSession.finishTasksAndInvalidate()
    }
}
extension NetworkManager {
    func setupRequest(with urlRequest: inout URLRequest) {
        urlRequest.timeoutInterval = 600
        fetchDocumentFileTask = session.downloadTask(with: urlRequest)
        delegate?.download(willStartFor: document)
        fetchDocumentFileTask?.resume()
        session.finishTasksAndInvalidate()
    }
}

extension NetworkManager: URLSessionDelegate {
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
        if let sessionId = session.configuration.identifier {
            print("session identifier: \(sessionId), thread: \(Thread.current)")
        }
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            print ("didBecomeInvalidWithError: \(error)")
        }
    }
}

extension NetworkManager: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                return
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        isDownloading = false
        
        if responseContainsError(downloadTask.response) || self.taskCancelled == true {
            return
        }
        
        if let copyToFileURL = self.document.storeDownloadedFile(from: location) {
            delegate?.download(for: document, didFinishAt: copyToFileURL, with: nil)
        } else {
            delegate?.download(for: document, didFinishAt: nil, with: nil)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let responseHeaderFields: [AnyHashable: Any]
        
        if let httpResponse = downloadTask.response as? HTTPURLResponse {
            responseHeaderFields = httpResponse.allHeaderFields
            
            let totalSize = Units(bytes: totalBytesExpectedToWrite).getReadableUnit()
            let writtenSize = Units(bytes: totalBytesWritten).getReadableUnit()
            var displayValue = writtenSize+"/"+totalSize
            print(displayValue)
            if totalSize == writtenSize {
                displayValue = "Downloaded"
            }
            var contentLength = Double(totalBytesExpectedToWrite)
            
            if contentLength <= -1, let contentLengthValue = responseHeaderFields["Content-Length"] as? String {
                contentLength = Double(contentLengthValue) ?? 0.0
            }
            
            // Calculate the percent complete
            let dBytesWritten = Double(totalBytesWritten)
            
            let completed = dBytesWritten / contentLength * 100
            
            if Int(completed) < 5 || !isDownloading {
                isDownloading = true
                delegate?.download(didStartFor: document)
            }
            
            delegate?.downloadProgress(for: document, isAt: displayValue)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print(#function)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        responseContainsError(task.response, error: error)
    }

}
