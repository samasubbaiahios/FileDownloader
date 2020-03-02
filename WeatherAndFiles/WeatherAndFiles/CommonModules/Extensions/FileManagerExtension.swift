//
//  FileManagerExtension.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

extension FileManager {
    func documentDirectoryPath() throws -> String? {
        var docDir: String?
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            docDir = documentsURL.path
        } catch {
            print("could not get docDirPath due to FileManager error: \(error)")
        }
        return docDir
    }
    
    func documentDirectoryURL() throws -> URL {
        var documentDirURL: URL
        
        do {
            documentDirURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
        } catch {
            print("could not get docDirURL due to FileManager error: \(error)")
            throw error
        }
        
        return documentDirURL
    }
    
    func systemCacheDirectoryURL() throws -> URL {
        let cacheDir = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cacheDir
    }
    
    func cacheFileURL(forFile fileName: String) throws -> URL {
        var jsonDataFileURL: URL
        
        do {
            let docDirURL = try FileManager.default.documentDirectoryURL()
            jsonDataFileURL = docDirURL.appendingPathComponent(fileName)
        } catch {
            print("could not find file due to an error: \(error)")
            throw error
        }
        
        return jsonDataFileURL
    }
    
    func docCacheDirectory(forModule moduleName: String, subDir: String?=nil) throws -> URL {
        let moduleCacheFolder: URL
        
        do {
            let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let childDir = subDir ?? ""
            let cacheFolderPath = String(format: "Caches/%@", moduleName, childDir)
            moduleCacheFolder = docDir.appendingPathComponent(cacheFolderPath)
            if !FileManager.default.fileExists(atPath: moduleCacheFolder.path) {
                try FileManager.default.createDirectory(at: moduleCacheFolder, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Could not create \(moduleName) directory under document cache folder due to error: \(error)")
            throw error
        }
        
        return moduleCacheFolder
    }
}
