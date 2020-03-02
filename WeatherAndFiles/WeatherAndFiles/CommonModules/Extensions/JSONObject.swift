//
//  JSONObject.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum JSONValueType: Int {
    case string, number, boolean, date, array, dictionary, null, unknown
}

struct JSONObject {

}

extension JSONObject {
    func stringValue() -> String? {
        return ""
    }
}
