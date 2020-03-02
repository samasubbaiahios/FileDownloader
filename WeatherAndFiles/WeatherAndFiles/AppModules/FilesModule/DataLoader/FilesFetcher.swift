//
//  FilesFetcher.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

class FilesFetcher {
    class func getFilesFromServer(fileData: File) {
        //https://www.gstatic.com/webp/gallery/1.jpg --> small file
        //https://speed.hetzner.de/10GB.bin --> large file
        let fetchOPs = NewFileDownloadOperation.init(downloadFile: fileData) { }
        fetchOPs?.execute()
    }
}
class NewFileDownloadOperation: BaseGroupOperation {
    
    fileprivate var completionHandler:(() -> Void)?
    fileprivate let getFileOp: GetFileOperation
    var completedSuccessfully = false
    
    var fileDownloadProgress = Observable("")
    var fileDownloadInitiated: Observable<DownloadStatus>? = Observable(.NotStarted)

    init?(downloadFile: File, completionHandler: @escaping () -> Void) {
        
        self.completionHandler = completionHandler
        var ops = [Operation]()
        getFileOp = GetFileOperation(downloadDoc: downloadFile)
        ops.append(getFileOp)
        super.init(ops: ops)
        
        name = "ORADrawingDownloadOperation"
        
        downloadFile.downloadStatus = Observable("")
        downloadFile.errorMessage = Observable("")
        downloadFile.downloadStatus?.bind(observer: { [weak self] (_, percentComplete) in
            self?.fileDownloadProgress.value = percentComplete
        })
        
        downloadFile.downloadInitiated?.bind(observer: { [weak self] (_, downloadStarted) in
            self?.fileDownloadInitiated?.value = DownloadStatus.Started
        })
    }
    
    override func finished(with errors: [Error]) {
        
        if errors.isEmpty {
            completedSuccessfully = true
        }
        super.finished(with: errors)
        executeCompletionHandler(fromCommand: "Finish")
    }
    
    override func cancel() {
        if !isCancelled {
            super.cancel()
            executeCompletionHandler(fromCommand: "Cancel")
        }
    }
    
    private func executeCompletionHandler(fromCommand command: String) {
        if let completionCallback = completionHandler {
            print("\(command) operation with id = \(operationLinkingId)")
            completionCallback()
            completionHandler = nil
        }
    }
    
    override func operationDidFinish(_ operation: Operation, with errors: [Error]) {
        super.operationDidFinish(operation, with: errors)
        if !errors.isEmpty {
            for otherOp in self.operations where (otherOp != operation && otherOp != self) {
                if let baseAsyncOp = otherOp as? BaseAsyncOperation {
                    baseAsyncOp.cancel()
                }
            }
        }
    }
    
    deinit {
    }
}


class GetFileOperation: FileDownloadOperation {

    init(downloadDoc: File) {
        super.init(downloadableDoc: downloadDoc)
        name = "Get file"
    }

    override func execute() {
        super.execute()

    }
    deinit {
    }
}
