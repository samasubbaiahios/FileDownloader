//
//  FilesViewModel.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 23/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FilesViewModel: NSObject {
    var filesLog: Observable<[File]> = Observable()
    var orignalLog = [File]()
    override init() {
        super.init()
    }
    
    func addFileToList(filePath: String) {
        if let existingFiles = filesLog.value {
            self.orignalLog = existingFiles
        }
        let fileModel = File.init(fileURLString: filePath)
        if self.orignalLog.contains(where: { $0.fileURL == fileModel.fileURL }) == false {
            FilesFetcher.getFilesFromServer(fileData: fileModel)
            self.orignalLog.append(fileModel)
        }
        self.filesLog.value = self.orignalLog
    }
}
