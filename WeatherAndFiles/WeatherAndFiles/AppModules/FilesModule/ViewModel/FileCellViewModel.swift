//
//  FileCellViewModel.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 23/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

class FileCellViewModel: NSObject {
    var filesLog : File

    init(log: File) {
        self.filesLog = log
    }
    
    func getLog() -> File {
        return filesLog
    }
}
