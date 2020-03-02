//
//  File.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 23/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
@objc enum DownloadStatus : Int {
    case NotStarted = 0, Started, InProgress, Finished
}

class File {
    var fileName: String
    var downloadStatus: Observable<String>?
    var errorMessage: Observable<String>?
    var downloadInitiated: Observable<DownloadStatus>? = Observable(.NotStarted)
    var fileURL: URL?

    init(fileURLString: String) {
        let composedURL = URL(string: fileURLString)
        self.fileURL = composedURL
        self.fileName = (fileURLString as NSString).lastPathComponent
    }
    
    var docCacheDirURL: URL? {
        return try? FileManager.default.documentDirectoryURL()
    }
    
    var systemCacheDirURL: URL? {
        return try? FileManager.default.systemCacheDirectoryURL()
    }
    
    func storeDownloadedFile(from location: URL) -> URL? {
        var newLocationURL: URL?
        
        do {
            let savedFileURL = self.docCacheDirURL?.appendingPathComponent(self.fileName)
            
            guard let copyToFileURL = savedFileURL else {
                print("Could not store the downloaded file from location: \(location.path) to new location")
                return newLocationURL
            }
            
            if FileManager.default.fileExists(atPath: copyToFileURL.path) {
                try? FileManager.default.removeItem(at: copyToFileURL)
            }
            
            try FileManager.default.moveItem(at: location, to: copyToFileURL)
            newLocationURL = copyToFileURL
        } catch {
            print("Could not store the downloaded file from location: \(location.path) to new location due to error: \(error)")
        }
        
        return newLocationURL
    }
    
    func copyFile(from location: URL) -> URL? {
        var newLocationURL: URL?
        
        do {
            let savedFileURL = self.docCacheDirURL?.appendingPathComponent(self.fileName)
            
            guard let copyToFileURL = savedFileURL else {
                print("Could not store the downloaded file from location: \(location.path) to new location")
                return newLocationURL
            }
            
            if FileManager.default.fileExists(atPath: copyToFileURL.path) {
                try? FileManager.default.removeItem(at: copyToFileURL)
            }
            
            try FileManager.default.copyItem(at: location, to: copyToFileURL)
            newLocationURL = copyToFileURL
        } catch {
            print("Could not store the downloaded file from location: \(location.path) to new location due to error: \(error)")
        }
        
        return newLocationURL
    }
}

protocol Downloadable: class {
    func download(willStartFor document: File)
    func download(didStartFor document: File)
    func download(for document: File, didFinishAt location: URL?, with error: Error?)
    func downloadProgress(for document: File, isAt percentCompleted: String)
}
