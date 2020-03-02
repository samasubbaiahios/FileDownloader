//
//  FilesViewController.swift
//  WeatherAndFiles
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit

class FilesViewController: UIViewController {
    static let kDownloadProgressNotification = "DownloadProgressNotification"

    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var filesListTable: UITableView!
    @IBOutlet weak var downloadImage: UIImageView!
    // MARK: Variables
    var filesViewModel: FilesViewModel?
    var filesViewModeldataSource: FilesDataSource?
    
    @IBOutlet weak var downloadButton: UIButton! {
        didSet {
            downloadButton.addTarget(self, action: #selector(downloadFile), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.filesViewModeldataSource = FilesDataSource()
        self.filesViewModeldataSource?.getfilesViewModel = self
        self.filesListTable.dataSource = filesViewModeldataSource
        uiStyles()
        self.filesListTable.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(FilesViewController.kDownloadProgressNotification), object: nil)    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: FilesViewController.kDownloadProgressNotification), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification){
        // Take Action on Notification
        DispatchQueue.main.async {
            self.filesListTable.reloadData()
        }
    }
    func uiStyles() {
        self.filesListTable.rowHeight = UITableView.automaticDimension
        self.filesListTable.estimatedRowHeight = UITableView.automaticDimension
        self.filesListTable.tableFooterView = UIView()
        self.urlField.layer.cornerRadius = 6
        self.urlField.backgroundColor = UIColor.lightText
        self.downloadButton.layer.cornerRadius = 5
    }
    // MARK: - Actions
    /// Download Action
    @objc
    private func downloadFile() {
        self.view.endEditing(true)
        guard let text = urlField.text, !text.isEmpty else {
            return
        }
        if self.verifyUrl(urlString: text) {
            self.filesViewModel?.addFileToList(filePath: text)
            urlField.text = ""
        }
    }
    ///URL validation
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - UITextFieldDelegate
extension FilesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case urlField:
            downloadFile()
        default: return true
        }
        return true
    }
}

@objc extension FilesViewController: Configurable {
    typealias T = FilesViewModel
    func bind(to model: FilesViewModel) {
        self.filesViewModel = model
        self.filesViewModel?.observe(for: [self.filesViewModel!.filesLog], with: { [weak self] (_) in
            self?.filesListTable.dataSource = self?.filesViewModeldataSource
            self?.filesListTable.reloadData()
        })
    }
}

