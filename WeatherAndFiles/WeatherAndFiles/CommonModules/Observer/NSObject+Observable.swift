//
//  NSObject+Observable.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 21/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

extension NSObject {
    func observe<T>(for observables: [Observable<T>], with: @escaping (T) -> Void) {
        for observable in observables {
            observable.bind { (_, value)  in
                DispatchQueue.main.async {
                    with(value)
                }
            }
        }
    }
}
