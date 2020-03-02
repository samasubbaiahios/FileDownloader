//
//  FilesDataSource.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 23/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FilesDataSource: NSObject {
    var filesListTable: UITableView!
    var getfilesViewModel: FilesViewController?
}

extension FilesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let logList = self.getfilesViewModel?.filesViewModel?.filesLog.value {
            return logList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilesTableViewCell.kFileCellId) as! FilesTableViewCell
        if let logList = self.getfilesViewModel?.filesViewModel?.filesLog.value {
            cell.bind(to: FileCellViewModel(log: logList[indexPath.row]))
        }
        return cell
    }
}
