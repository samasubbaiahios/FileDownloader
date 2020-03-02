//
//  FilesTableViewCell.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 22/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FilesTableViewCell: UITableViewCell {
    static let kFileCellId = "filesCell"

    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var filePinImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var viewModel: FileCellViewModel? {
        didSet {
            let fileModel: File = viewModel?.getLog() ?? File.init(fileURLString: "sample")
            self.fileNameLabel.text = fileModel.fileName
            self.fileNameLabel.font = UIFont.systemFont(ofSize: 16)
            self.fileNameLabel.textColor = UIColor.black
            
            self.downloadLabel.text = fileModel.downloadStatus?.value
            self.downloadLabel.font = UIFont.systemFont(ofSize: 15)
            self.downloadLabel.textColor = UIColor.lightGray
            if !(fileModel.errorMessage?.value?.isEmpty)! {
                self.downloadLabel.text = fileModel.errorMessage?.value
                self.downloadLabel.textColor = UIColor.red
            }
        }
    }
}
@objc extension FilesTableViewCell: Configurable {
    typealias T = FileCellViewModel
    func bind(to model: FileCellViewModel) {
        self.viewModel = model
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
