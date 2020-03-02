//
//  FileDownloadOperation.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

class FileDownloadOperation: BaseAsyncOperation, Downloadable {
    let downloadableDoc: File
    var fileDownloader: DownloadManager?
    
    var fileURL: URL? {
        return downloadableDoc.fileURL
    }
    
    init(downloadableDoc: File) {
        self.downloadableDoc = downloadableDoc
        super.init()
        name = "Get File"
    }
    
    override func execute() {
        self.fetchFile()
    }
    
    override func cancel() {
        fileDownloader?.stopDownload()
        super.cancel()
    }
    
    func fetchFile() {
        updateRequestHeaders()
        
        guard let fileURL = fileURL else {
            let errorMessage = "URL MISSING"
            let error = NSError(domain: "ServerErrorDomain", code: 500, userInfo: [NSLocalizedFailureReasonErrorKey: errorMessage, NSLocalizedDescriptionKey: errorMessage])
            self.finish(with: [error])
            return
        }
        print(fileURL.absoluteString)
        if isCancelled {
            self.finish(true)
            return
        }
        
        let fileDownloader = DownloadManager(document: self.downloadableDoc)
        fileDownloader.delegate = self
        fileDownloader.startDownload()
        self.fileDownloader = fileDownloader
    }
    
    func updateRequestHeaders() { }
    
    func download(for document: File, didFinishAt location: URL?, with error: Error?) {
        var errors = [Error]()
        
        if isCancelled {
            self.downloadableDoc.downloadStatus?.value = ""
            self.finish(true)
            return
        }
        
        if error == nil {
            self.downloadableDoc.downloadStatus?.value = "Downloaded"
        } else if !self.isCancelled {
            if let error = error {
                errors.append(error)
            }
            self.downloadableDoc.errorMessage?.value = error?.localizedDescription
        }
        
        // on successful finish
        downloadableDoc.downloadInitiated?.value = DownloadStatus.Finished
        self.finish(with: errors)
    }
    
    func downloadProgress(for document: File, isAt percentCompleted: String) {
        if isCancelled {
            self.finish(true)
            return
        }
        downloadableDoc.downloadInitiated?.value = DownloadStatus.InProgress
        self.downloadableDoc.downloadStatus?.value = percentCompleted
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FilesViewController.kDownloadProgressNotification), object: nil)

    }
    
    deinit {
    }
    
    func download(willStartFor document: File) {
        self.downloadableDoc.downloadStatus?.value = "Downloading"
    }
    
    func download(didStartFor document: File) {
        downloadableDoc.downloadInitiated?.value = DownloadStatus.Started
    }
}
