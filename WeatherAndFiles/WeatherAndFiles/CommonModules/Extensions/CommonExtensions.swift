//
//  CommonExtensions.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 23/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    /// Initialises Any type of UIViewController
    ///
    /// - Parameters:
    ///   - type: A generic instance of type UIViewController
    ///   - storyboardName: A String value which defines the storyboard name from which the UIViewController should be initialised
    ///   - storyboardId: A String value which defines an unique identifier for each UIViewController instance
    ///   - bundle: A Bundle instance
    /// - Returns: Type of UIViewController
    class func getViewController<T>(ofType type: T.Type,
                                    fromStoryboardName storyboardName: String,
                                    storyboardId: String,
                                    bundle: Bundle) -> T? where T: UIViewController {
        let designatedViewController = UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: storyboardId)
        return designatedViewController as? T
    }
    
    /// Gives an UIViewController instance whose underneath controller is UINavigationController
    func notNavigationController() -> UIViewController? {
        if let nav = self as? UINavigationController {
            return nav.topViewController?.notNavigationController()
        }
        return self
    }
    
    /// Create a new empty controller instance with given view
    ///
    /// - Parameters:
    ///   - view: view
    ///   - frame: frame
    /// - Returns: instance
    static func newController(withView view: UIView, frame: CGRect) -> UIViewController {
        view.frame = frame
        let controller = UIViewController()
        controller.view = view
        return controller
    }
}

extension UIImage {
    /// Fills an UIImage with given color
    ///
    /// - Parameters:
    ///   - color: An UIColor instance which would be applied to the image
    /// - Returns: Modified image
    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1))
        return drawInContext(rect: rect) { context in
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
    }
    class func circularImage(with color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        return drawInContext(rect: rect) { context in
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: rect)
        }
    }
}

private extension UIImage {
    class func drawInContext(rect: CGRect, drawing: (CGContext) -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        drawing(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
