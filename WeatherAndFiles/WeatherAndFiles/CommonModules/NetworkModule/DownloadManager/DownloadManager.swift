//
//  DownloadManager.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

typealias HTTPHeader = [String: String]

class DownloadManager: NSObject {
    weak var delegate: Downloadable?
    var url: URL
    var document: File
    var fetchDocumentFileTask: URLSessionDownloadTask?
    var additionalHTTPHeaders: HTTPHeader?
    var isDownloading = false
    var taskCancelled = false
    
    private lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 600
        return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }()
    
    init(document: File) {
        self.document = document
        self.url = document.fileURL!
    }
    
    func startDownload() {
        var urlRequest = URLRequest(url: self.url)
        setupRequest(with: &urlRequest)
    }
    
    func startExportPDFDownload() {
        var urlRequest = URLRequest(url: self.url)
        setupRequest(with: &urlRequest)
    }
    
    func stopDownload() {
        isDownloading = false
        taskCancelled = true
        fetchDocumentFileTask?.cancel()
        fetchDocumentFileTask = nil
        print("download is cancelled")
    }
    
    func pauseDownload() {
        isDownloading = false
        fetchDocumentFileTask?.cancel(byProducingResumeData: { data in
            print("downloaded data size = \(data?.count ?? 0)")
        })
    }
    
    func resumeDownload() {
        isDownloading = true
    }
    
    @discardableResult
    func responseContainsError(_ urlResponse: URLResponse?, error: Error? = nil) -> Bool {
        if let err = error as NSError? {
            delegate?.download(for: document, didFinishAt: nil, with: err)
            return true
        }
        
        guard let httpResponse = urlResponse as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print("httpResponse: \(String(describing: urlResponse))")
                delegate?.download(for: document, didFinishAt: nil, with: error)
                return true
        }
        return false
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
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

extension DownloadManager: URLSessionDelegate {
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

private extension DownloadManager {
    func setupRequest(with urlRequest: inout URLRequest) {
        urlRequest.timeoutInterval = 600
        fetchDocumentFileTask = session.downloadTask(with: urlRequest)
        delegate?.download(willStartFor: document)
        fetchDocumentFileTask?.resume()
        session.finishTasksAndInvalidate()
    }
}
